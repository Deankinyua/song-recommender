defmodule SongRecommender.RecommendationEngine do
  @moduledoc """
  The recommendation system powering the application.
  Determines the recommendation strategy.
  Uses a combination of collaborative filtering and content-based filtering
  """

  use GenServer, restart: :transient

  alias SongRecommender.EngineRegistry

  @spec start_link(any()) :: GenServer.on_start()
  def start_link(opts), do: GenServer.start_link(__MODULE__, %{}, opts)

  @impl GenServer
  def init(state), do: {:ok, state}

  defp via_registry(name), do: {:via, Registry, {EngineRegistry, name}}
end
