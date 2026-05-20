defmodule SongRecommender.SongQueue do
  @moduledoc """
  Keeps a record of the songs a user has listened to and
  later persists them to Neo4j. It also makes requests to the
  recommendation engine to get new songs then delivers them
  back to the LiveView.
  """

  use GenServer, restart: :transient

  @spec start_link(any()) :: GenServer.on_start()
  def start_link(opts) do
    username = Keyword.get(opts, :username)
    GenServer.start_link(__MODULE__, %{username: username}, opts)
  end

  @impl GenServer
  def init(state), do: {:ok, state, {:continue, :initialize_queue}}

  @impl GenServer
  def handle_continue(:initialize_queue, %{username: username} = state) do
    engine_name = engine_name(username)
    new_state = Map.put(state, :engine_name, engine_name)

    {:noreply, new_state}
  end

  defp engine_name(username), do: "#{username}_recommendation_engine"
end
