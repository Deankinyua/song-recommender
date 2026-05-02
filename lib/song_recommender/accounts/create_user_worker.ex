defmodule SongRecommender.Accounts.CreateUserWorker do
  @moduledoc """
  Creates a fake user.
  """

  use Oban.Worker,
    max_attempts: 3,
    queue: :create_user

  alias SongRecommender.Accounts
  alias SongRecommender.Accounts.CreateHistoryWorker

  @total_minutes_per_genre 35

  @type job :: Oban.Job.t()

  @impl Oban.Worker
  def perform(%Oban.Job{
        args: %{"listening_history" => listening_history} = args
      }) do
    case Accounts.register_user(args) do
      {:ok, user} ->
        song_distribution = songs_per_genre(listening_history)

        CreateHistoryWorker.enqueue(%{
          "name" => user.name,
          "song_distribution" => song_distribution
        })

        :ok

      {:error, _changeset} ->
        {:error, "failed to create user"}
    end
  end

  defp songs_per_genre(listening_history) do
    Enum.map(listening_history, fn {genre, minutes} ->
      songs_per_genre = div(minutes, @total_minutes_per_genre)

      %{genre: genre, limit: songs_per_genre}
    end)
  end

  @spec enqueue(map()) :: {:ok, job()} | {:error, Ecto.Changeset.t()}
  def enqueue(attrs) do
    attrs
    |> __MODULE__.new()
    |> Oban.insert()
  end
end
