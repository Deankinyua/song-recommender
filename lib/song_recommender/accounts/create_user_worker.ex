defmodule SongRecommender.Accounts.CreateUserWorker do
  @moduledoc """
  Creates a fake user.
  """

  use Oban.Worker,
    max_attempts: 3,
    queue: :create_user

  alias SongRecommender.Accounts
  alias SongRecommender.Songs.CreateSongHistoryWorker

  @type job :: Oban.Job.t()

  @impl Oban.Worker
  def perform(%Oban.Job{
        args: %{"listening_history" => listening_history} = args
      }) do
    case Accounts.register_user(args) do
      {:ok, user} ->
        CreateSongHistoryWorker.enqueue(%{
          "name" => user.name,
          "song_distribution" => listening_history
        })

        :ok

      {:error, _changeset} ->
        {:error, "Failed to create the user"}
    end
  end

  @spec enqueue(map()) :: {:ok, job()} | {:error, Ecto.Changeset.t()}
  def enqueue(attrs) do
    attrs
    |> __MODULE__.new()
    |> Oban.insert()
  end
end
