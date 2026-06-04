defmodule SongRecommender.Songs.CreateSongHistoryWorker do
  @moduledoc """
  Creates listening history for a single user.
  A limit exists inside the song_distribution details
  and it determines the number of songs to add LISTENED_TO
  relationships.
  """

  use Oban.Worker,
    max_attempts: 1,
    queue: :set_song_history

  alias SongRecommender.Songs

  @chunk_size 10

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
      |> Enum.map(&process_songs(&1, username, genre))
    end)
  end

  defp process_songs(songs, username, genre) do
    Enum.each(songs, fn _song ->
      Songs.listen_from_genre(username, genre)
    end)
  end

  @spec enqueue(map()) :: {:ok, job()} | {:error, Ecto.Changeset.t()}
  def enqueue(attrs) do
    attrs
    |> __MODULE__.new()
    |> Oban.insert()
  end
end
