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

  alias SongRecommender.Artists
  alias SongRecommender.EngineQueueRegistry
  alias SongRecommender.EngineQueueSupervisor
  alias SongRecommender.Genres

  @type engine :: String.t()

  @threshold_listening_time_ms 3_600_000
  @timeout 1_200_000

  @spec start_link(any()) :: GenServer.on_start()
  def start_link(opts) do
    username = Keyword.get(opts, :username)
    GenServer.start_link(__MODULE__, %{username: username}, opts)
  end

  @impl GenServer
  def init(state), do: {:ok, state, {:continue, :initialize_engine}}

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
      |> Map.put(:queue_name, queue_name)
      |> Map.put(:strategy, recommendation_strategy)
      |> Map.put(:taste_profile, taste_profile)

    {:noreply, new_state, @timeout}
  end

  @spec get_initial_songs(engine()) :: :ok
  def get_initial_songs(engine),
    do: make_engine_request(engine, :cast, :get_initial_songs)

  @impl GenServer
  def handle_cast(:get_initial_songs, state) do
    dbg(state)
    {:noreply, state}
  end

  @impl GenServer
  def handle_info(:timeout, %{queue_name: queue_name} = state) do
    EngineQueueSupervisor.stop_queue(queue_name)
    {:stop, :normal, state}
  end

  defp determine_recommendation_strategy(total_listening_time) do
    if total_listening_time > @threshold_listening_time_ms,
      do: :hybrid,
      else: :genre_based
  end

  defp fetch_recommendation_utility_data(:genre_based, username) do
    genres = Genres.get_user_genres(username)
    artists = Artists.get_followed_artists(username)

    %{genres: genres, artists: artists}
  end

  defp fetch_recommendation_utility_data(:hybrid, _username), do: %{}

  defp make_engine_request(engine, request_type, message) when request_type == :call do
    engine
    |> via_registry()
    |> GenServer.call(message)
  end

  defp make_engine_request(engine, _request_type, message) do
    engine
    |> via_registry()
    |> GenServer.cast(message)
  end

  defp via_registry(name), do: {:via, Registry, {EngineQueueRegistry, name}}

  defp queue_name(username), do: "#{username}_song_queue"
end
