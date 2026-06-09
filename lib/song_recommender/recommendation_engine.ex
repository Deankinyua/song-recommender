defmodule SongRecommender.RecommendationEngine do
  @moduledoc """
  The recommendation system powering the application.
  Determines the recommendation strategy.
  2 recommendation strategies exist: :genre_based and :hybrid.
  :genre_based is used for a user whose listening history does not exceed 60 minutes.
  :hybrid is used when the listening history exceeds 60 minutes; it is
  a combination of collaborative filtering and content-based filtering.
  """

  use GenServer, restart: :transient

  import SongRecommender.GenserverHelpers

  alias SongRecommender.Artists
  alias SongRecommender.EngineQueueSupervisor
  alias SongRecommender.Genres
  alias SongRecommender.QueryEngine
  alias SongRecommender.Songs
  alias SongRecommender.Songs.Song

  @ideal_song_number 16
  @just_followed_artists_threshold 3
  @just_unfollowed_artists_threshold 2
  @threshold_listening_time_ms 3_600_000
  @timeout 1_200_000

  @type engine_name :: String.t()
  @type song :: Song.t()

  @spec start_link(any()) :: GenServer.on_start()
  def start_link(opts) do
    username = Keyword.get(opts, :username)
    GenServer.start_link(__MODULE__, %{username: username}, opts)
  end

  @impl GenServer
  def init(state), do: {:ok, state, {:continue, :initialize_engine}}

  @spec maybe_change_taste_profile(engine_name()) ::
          {:ok, :profile_changed} | {:error, :profile_should_not_change}
  def maybe_change_taste_profile(engine_name),
    do: make_genserver_request(engine_name, :call, :change_taste_profile)

  @spec recommend_new_songs(engine_name()) :: :ok
  def recommend_new_songs(engine_name), do: make_genserver_request(engine_name, :cast, :get_songs)

  @spec track_followed_artist(engine_name()) :: :ok
  def track_followed_artist(engine_name),
    do: make_genserver_request(engine_name, :cast, :artist_followed)

  @spec track_unfollowed_artist(engine_name()) :: :ok
  def track_unfollowed_artist(engine_name),
    do: make_genserver_request(engine_name, :cast, :artist_unfollowed)

  @spec recommend_with_song(engine_name(), song()) :: :ok
  def recommend_with_song(engine_name, song) do
    song_information = extract_song_information(song)
    make_genserver_request(engine_name, :cast, {:recommend_similar_songs, song_information})
  end

  @impl GenServer
  def handle_continue(:initialize_engine, %{username: username} = state) do
    recommendation_strategy =
      username
      |> Genres.calculate_total_listening_time()
      |> determine_recommendation_strategy()

    taste_profile = fetch_recommendation_utility_data(recommendation_strategy, username)

    queue_name = queue_name(username)

    new_state =
      state
      |> Map.put(:followed_artists, 0)
      |> Map.put(:queue_name, queue_name)
      |> Map.put(:strategy, recommendation_strategy)
      |> Map.put(:taste_profile, taste_profile)
      |> Map.put(:unfollowed_artists, 0)

    {:noreply, new_state, @timeout}
  end

  @impl GenServer
  def handle_cast(
        :get_songs,
        %{
          queue_name: queue_name,
          strategy: strategy,
          taste_profile: taste_profile,
          username: username
        } = state
      ) do
    :ok =
      strategy
      |> QueryEngine.get_songs(username, taste_profile)
      |> send_songs_to_queue(queue_name)

    {:noreply, state, @timeout}
  end

  def handle_cast({:recommend_similar_songs, song_information}, %{queue_name: queue_name} = state) do
    :ok =
      song_information
      |> QueryEngine.get_similar_songs()
      |> send_songs_to_queue(queue_name)

    {:noreply, state, @timeout}
  end

  def handle_cast(
        :artist_followed,
        %{
          followed_artists: followed_artists,
          strategy: recommendation_strategy,
          username: username
        } = state
      ) do
    new_state =
      case followed_artists < @just_followed_artists_threshold do
        true ->
          Map.put(state, :followed_artists, followed_artists + 1)

        false ->
          taste_profile = fetch_recommendation_utility_data(recommendation_strategy, username)

          state
          |> Map.put(:followed_artists, 1)
          |> Map.put(:taste_profile, taste_profile)
      end

    {:noreply, new_state, @timeout}
  end

  def handle_cast(
        :artist_unfollowed,
        %{
          unfollowed_artists: unfollowed_artists,
          strategy: recommendation_strategy,
          username: username
        } = state
      ) do
    new_state =
      case unfollowed_artists < @just_unfollowed_artists_threshold do
        true ->
          Map.put(state, :unfollowed_artists, unfollowed_artists + 1)

        false ->
          taste_profile = fetch_recommendation_utility_data(recommendation_strategy, username)

          state
          |> Map.put(:unfollowed_artists, 1)
          |> Map.put(:taste_profile, taste_profile)
      end

    {:noreply, new_state, @timeout}
  end

  @impl GenServer
  def handle_call(
        :change_taste_profile,
        _from,
        %{queue_name: queue_name, strategy: strategy, username: username} = state
      )
      when strategy == :genre_based do
    taste_profile = fetch_recommendation_utility_data(strategy, username)

    :ok =
      username
      |> Songs.get_songs_with_genre_based_strategy(taste_profile)
      |> send_songs_to_queue(queue_name)

    new_state = Map.put(state, :taste_profile, taste_profile)

    {:reply, {:ok, :profile_changed}, new_state, @timeout}
  end

  def handle_call(:change_taste_profile, _from, %{strategy: :hybrid} = state),
    do: {:reply, {:error, :profile_should_not_change}, state, @timeout}

  @impl GenServer
  def handle_info(:timeout, %{queue_name: queue_name} = state) do
    EngineQueueSupervisor.stop_queue(queue_name)
    {:stop, :normal, state}
  end

  defp extract_song_information(%Song{id: id, artist: artist, genre: genre}),
    do: %{id: id, artist_name: artist.name, genre_name: genre.name, randomizer: :rand.uniform(20)}

  defp send_songs_to_queue(songs, queue_name),
    do: make_genserver_request(queue_name, :call, {:recommended_songs, songs})

  defp determine_recommendation_strategy(total_listening_time) do
    if total_listening_time > @threshold_listening_time_ms,
      do: :hybrid,
      else: :genre_based
  end

  defp fetch_recommendation_utility_data(:genre_based, username) do
    retrieved_artists = Artists.get_followed_artists(username)
    artists = group_by_limit(retrieved_artists)

    retrieved_genres = Genres.get_user_genres(username)

    genres =
      if Enum.empty?(retrieved_artists),
        do: group_by_limit(retrieved_genres, @ideal_song_number),
        else: group_by_limit(retrieved_genres)

    %{artists: artists, genres: genres}
  end

  defp fetch_recommendation_utility_data(:hybrid, _username), do: %{}

  defp group_by_limit(node_list, songs_per_node_type \\ @ideal_song_number / 2)

  defp group_by_limit(node_list, _songs_per_node_type) when node_list == [],
    do: %{nodes: [], limit: 0}

  defp group_by_limit(node_list, songs_per_node_type) do
    count = Enum.count(node_list)
    song_limit = :math.ceil(songs_per_node_type / count) |> trunc()

    %{nodes: node_list, limit: song_limit}
  end

  defp queue_name(username), do: "#{username}_song_queue"
end
