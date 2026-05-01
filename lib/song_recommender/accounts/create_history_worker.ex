defmodule SongRecommender.Accounts.CreateHistoryWorker do
  @moduledoc """
  Creates listening history for a single user.
  A limit exists inside the song_distribution details
  We will fetch 5 sets of (limit) songs and add LISTENED_TO relationships
  to each song with a property of duration_played_ms defined in the
  attribute song_duration_ms
  """

  use Oban.Worker,
    max_attempts: 3,
    queue: :set_song_history

  alias SongRecommender.Songs

  @chunk_size 10
  @ms_per_minute 60_000
  @song_duration_minutes [15, 8, 5, 4, 3]

  @type job :: Oban.Job.t()

  @impl Oban.Worker
  def perform(%Oban.Job{
        args: %{"name" => username, "song_distribution" => song_distribution}
      }) do
    generate_history_per_user(username, song_distribution)
    :ok
  end

  defp generate_history_per_user(username, song_distribution) do
    Enum.each(song_distribution, fn %{"limit" => limit, "genre" => genre} ->
      1..limit
      |> Stream.chunk_every(@chunk_size)
      |> Enum.map(&process_chunk(&1, username, genre))
    end)
  end

  defp process_chunk(chunk, username, genre) do
    Enum.each(chunk, fn _num ->
      for duration <- @song_duration_minutes do
        duration_ms = duration * @ms_per_minute
        Songs.listen_from_genre(username, genre, duration_ms)
      end
    end)
  end

  @spec enqueue(map()) :: {:ok, job()} | {:error, Ecto.Changeset.t()}
  def enqueue(attrs) do
    attrs
    |> __MODULE__.new()
    |> Oban.insert()
  end
end
