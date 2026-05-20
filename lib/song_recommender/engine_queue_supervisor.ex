defmodule SongRecommender.EngineQueueSupervisor do
  @moduledoc """
  Responsible for starting recommendation engines and song queues per user.
  Each user gets an instance each of the respective resources.
  """

  use DynamicSupervisor

  alias SongRecommender.EngineQueueRegistry
  alias SongRecommender.RecommendationEngine
  alias SongRecommender.SongQueue

  @type engine_name :: String.t()
  @type queue_name :: String.t()
  @type username :: String.t()

  @spec start_link(any()) :: {:ok, pid()} | {:error, any()}
  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl DynamicSupervisor
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @spec start_engine(engine_name(), username()) :: DynamicSupervisor.on_start_child()
  def start_engine(engine_name, username) do
    DynamicSupervisor.start_child(
      {:via, PartitionSupervisor, {__MODULE__, self()}},
      {RecommendationEngine, name: via_registry(engine_name), username: username}
    )
  end

  @spec start_song_queue(queue_name(), username()) :: DynamicSupervisor.on_start_child()
  def start_song_queue(queue_name, username) do
    DynamicSupervisor.start_child(
      {:via, PartitionSupervisor, {__MODULE__, self()}},
      {SongQueue, name: via_registry(queue_name), username: username}
    )
  end

  @spec stop_queue(queue_name()) :: :ok
  def stop_queue(queue_name) do
    queue_name
    |> via_registry()
    |> GenServer.stop(:normal, 3000)
  end

  defp via_registry(name), do: {:via, Registry, {EngineQueueRegistry, name}}
end
