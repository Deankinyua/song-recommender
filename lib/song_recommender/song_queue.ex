defmodule SongRecommender.SongQueue do
  @moduledoc """
  Keeps a record of the songs a user has listened to and
  later persists them to Neo4j. It also makes requests to the
  recommendation engine to get new songs then delivers them
  back to the LiveView.
  """

  use GenServer, restart: :transient

  import SongRecommender.GenserverHelpers

  alias SongRecommender.Songs.Song

  @type duration_played :: integer()
  @type queue :: String.t()
  @type song :: Song.t()
  @type song_details :: [song_id() | duration_played()]
  @type song_id :: String.t()

  @spec start_link(any()) :: GenServer.on_start()
  def start_link(opts) do
    username = Keyword.get(opts, :username)

    state = %{
      previously_played_songs: [],
      previously_played_songs_count: 0,
      recommended_songs: [],
      recommended_songs_count: 0,
      username: username
    }

    GenServer.start_link(__MODULE__, state, opts)
  end

  @impl GenServer
  def init(state), do: {:ok, state, {:continue, :initialize_queue}}

  @impl GenServer
  def handle_continue(:initialize_queue, %{username: username} = state) do
    engine_name = engine_name(username)
    :ok = make_genserver_request(engine_name, :cast, :get_songs)
    new_state = Map.put(state, :engine_name, engine_name)

    {:noreply, new_state}
  end

  @impl GenServer
  def handle_call({:recommended_songs, new_songs}, _from, state) do
    new_state = update_recommended_songs(new_songs, state)
    {:reply, :ok, new_state}
  end

  def handle_call(:return_recommended_songs, _from, %{recommended_songs: songs} = state) do
    {:reply, songs, state}
  end

  @impl GenServer
  def handle_cast(
        {:persist_song, song_details},
        %{
          engine_name: engine,
          previously_played_songs: previously_played_songs,
          previously_played_songs_count: song_count,
          recommended_songs: recommended_songs,
          username: username
        } = state
      ) do
    case song_count < 4 do
      true ->
        previously_played_songs = [song_details | previously_played_songs]

        new_song_count = song_count + 1

        new_state =
          state
          |> Map.put(:previously_played_songs, previously_played_songs)
          |> Map.put(:previously_played_songs_count, new_song_count)

        {:noreply, new_state}

      false ->
        # check if all 4 are from the recommeded songs
        # update_listening_history here

        maybe_recommend_new_songs(engine, previously_played_songs, recommended_songs)

        new_state =
          state
          |> Map.put(:previously_played_songs, [song_details])
          |> Map.put(:previously_played_songs_count, 1)

        {:noreply, new_state}
    end
  end

  @spec get_recommended_songs(queue()) :: [song()]
  def get_recommended_songs(queue_name),
    do: make_genserver_request(queue_name, :call, :return_recommended_songs)

  @spec persist_played_song(queue(), song_details()) :: :ok
  def persist_played_song(queue_name, song_details),
    do: make_genserver_request(queue_name, :cast, {:persist_song, song_details})

  defp update_recommended_songs(
         songs,
         state
       ) do
    songs_count = Enum.count(songs)

    state
    |> Map.put(:recommended_songs, songs)
    |> Map.put(:recommended_songs_count, songs_count)
  end

  def maybe_recommend_new_songs(engine, played_songs, recommended_songs) do
    recommend? = Enum.all?(played_songs, &Enum.member?(recommended_songs, &1))

    if recommend?, do: make_genserver_request(engine, :cast, :get_songs), else: :ok
  end

  defp engine_name(username), do: "#{username}_recommendation_engine"
end
