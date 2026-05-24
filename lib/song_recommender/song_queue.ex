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

  @type queue :: String.t()
  @type song :: Song.t()

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
    :ok = make_genserver_request(engine_name, :cast, :get_initial_songs)
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

  @spec get_recommended_songs(queue()) :: [song()]
  def get_recommended_songs(queue_name),
    do: make_genserver_request(queue_name, :call, :return_recommended_songs)

  defp update_recommended_songs(
         songs,
         state
       ) do
    songs_count = Enum.count(songs)

    state
    |> Map.put(:recommended_songs, songs)
    |> Map.put(:recommended_songs_count, songs_count)
  end

  defp engine_name(username), do: "#{username}_recommendation_engine"
end
