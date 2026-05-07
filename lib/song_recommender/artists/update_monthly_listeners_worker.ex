defmodule SongRecommender.Artists.UpdateMonthlyListenersWorker do
  @moduledoc """
  Updates every artist's monthly listeners.
  """

  use Oban.Worker,
    max_attempts: 3,
    queue: :update_artist_listeners

  alias SongRecommender.Artists

  require Logger

  @type job :: Oban.Job.t()

  @impl Oban.Worker
  def perform(_job) do
    Logger.info("Updating all artists' listener count...", ansi_color: :green)
    Artists.update_monthly_listeners()
    Logger.info("Updated all artists' listener count", ansi_color: :green)
    :ok
  end

  @spec enqueue(map()) :: {:ok, job()} | {:error, Ecto.Changeset.t()}
  def enqueue(attrs \\ %{}) do
    attrs
    |> __MODULE__.new()
    |> Oban.insert()
  end
end
