defmodule SongRecommender.Songs.UpdateUserListeningHistoryWorker do
  @moduledoc """
  Updates the listening history of a user within a given session
  in batches of 3 songs each.
  """

  use Oban.Worker,
    max_attempts: 1,
    queue: :update_user_listening_history

  alias SongRecommender.Songs

  @type job :: Oban.Job.t()

  @impl Oban.Worker
  def perform(%Oban.Job{
        args: %{"username" => username, "songs" => songs}
      }) do
    Songs.persist_user_session_history(username, songs)

    :ok
  end

  @spec enqueue(map()) :: {:ok, job()} | {:error, Ecto.Changeset.t()}
  def enqueue(attrs) do
    attrs
    |> __MODULE__.new()
    |> Oban.insert()
  end
end
