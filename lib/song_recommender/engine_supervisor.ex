defmodule SongRecommender.EngineSupervisor do
  @moduledoc """
  Responsible for starting a recommendation engine instance.
  Each user gets their own instance of the recommendation engine.
  """

  use DynamicSupervisor

  alias SongRecommender.EngineRegistry
  alias SongRecommender.RecommendationEngine

  @type engine_name :: String.t()
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

  defp via_registry(name), do: {:via, Registry, {EngineRegistry, name}}
end
