defmodule CreateListeningHistory do
  @moduledoc """
  This is the fourth script that you should run. It does some
  calculated guesswork, using Zipf's Law to generate listening history.
  An official research paper by Juan I. Perotti et al finds that Zipf's law
  emerges when a combination of chords and notes are chosen as Zipfian units
  (https://arxiv.org/abs/1902.06678) Songs from the same genre might share
  similar characteristics; even though this is a bit of an oversimplification.
  That said, I used the genre as the Zipfian units. However, this will not account
  for much of the recommendations since we will rely more on content-based filtering.


  EDIT: I retired using this in the application
  """

  alias SongRecommender.Accounts.CreateUserWorker

  require Logger

  @chunk_size 20
  @max_percentage_for_a_genre 43..69
  @songs_threshold 120
  @zipf_exponent 0.96

  def start do
    Logger.info("Create fake users and their listening history...", ansi_color: :green)

    genre_categories = get_genre_categories()

    Enum.each(genre_categories, fn category ->
      # 50 users per group of genres
      1..50
      |> Stream.chunk_every(@chunk_size)
      |> Enum.map(&process_users(&1, category))
    end)

    Logger.info("Finished generating the listening history", ansi_color: :green)
  end

  defp process_users(users, category) do
    Enum.each(users, fn _user ->
      max_percentage = Enum.at(@max_percentage_for_a_genre, :rand.uniform(25))

      listening_history =
        calculate_genre_distribution(max_percentage, category, @songs_threshold)

      name_suffix = Ecto.UUID.generate()
      name = "User_#{name_suffix}"

      CreateUserWorker.enqueue(%{
        "name" => name,
        "listening_history" => listening_history
      })
    end)
  end

  defp calculate_genre_distribution(max_percentage, category, songs_threshold) do
    [lead_genre | other_genres] = Enum.shuffle(category)
    genre_count = Enum.count(category)
    lead_genre_songs = songs_threshold / 100 * max_percentage

    other_genres_songs =
      Enum.map(2..genre_count, fn rank ->
        coefficient = 1 / :math.pow(rank, @zipf_exponent)

        coefficient * lead_genre_songs
      end)

    other_genres_songs
    |> Enum.with_index()
    |> Enum.reduce(
      [%{genre: lead_genre, limit: truncate(lead_genre_songs)}],
      fn {songs, index}, acc ->
        genre = Enum.at(other_genres, index)

        [%{genre: genre, limit: truncate(songs)} | acc]
      end
    )
  end

  defp truncate(float) do
    float
    |> :math.floor()
    |> trunc()
  end

  defp get_genre_categories do
    [
      [
        "acoustic",
        "blues",
        "country",
        "guitar",
        "jazz"
      ],
      [
        "ambient",
        "chill",
        "trip-hop",
        "classical",
        "comedy"
      ],
      [
        "house",
        "deep-house",
        "chicago-house",
        "techno",
        "club"
      ],
      [
        "edm",
        "dance",
        "disco",
        "breakbeat",
        "dub"
      ],
      [
        "afrobeat",
        "dancehall",
        "funk",
        "soul",
        "gospel"
      ],
      [
        "alt-rock",
        "hard-rock",
        "metal",
        "heavy-metal",
        "pop"
      ],
      [
        "black-metal",
        "death-metal",
        "metalcore",
        "hip-hop",
        "k-pop"
      ]
    ]
  end
end

CreateListeningHistory.start()
