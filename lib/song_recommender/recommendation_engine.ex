defmodule SongRecommender.RecommendationEngine do
  @moduledoc """
  The recommendation system powering the application.
  Determines the recommendation strategy.
  Uses a combination of collaborative filtering and content-based filtering
  """

  use GenServer, restart: :transient

  alias SongRecommender.EngineRegistry

  @timeout 1_200_000

  @spec start_link(any()) :: GenServer.on_start()
  def start_link(opts), do: GenServer.start_link(__MODULE__, %{}, opts)

  @impl GenServer
  def init(state), do: {:ok, state, @timeout}

  @impl GenServer
  def handle_info(:timeout, state) do
    {:stop, :normal, state}
  end

  defp via_registry(name), do: {:via, Registry, {EngineRegistry, name}}
end
