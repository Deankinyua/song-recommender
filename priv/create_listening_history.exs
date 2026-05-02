defmodule CreateListeningHistory do
  @moduledoc """
  Calculated guesswork, using Zipf's Law to generate listening history.
  An official research paper by Juan I. Perotti et al finds that Zipf's law
  emerges when a combination of chords and notes are chosen as Zipfian units
  (https://arxiv.org/abs/1902.06678) Songs from the same genre might share
  similar characteristics; even though this is a bit of an oversimplification.
  That said, I used the genre as the Zipfian units.
  """

  alias SongRecommender.Accounts.CreateUserWorker

  require Logger

  @birth_date 1970..2005
  @chunk_size 20
  @listening_threshold_minutes 1200
  @max_percentage_for_a_genre 58..69
  @zipf_exponent 0.96

  def start do
    Logger.info("Preparing songs for traversal...", ansi_color: :green)
    prepare_songs_for_traversal()
    Logger.info("Marked relevant songs as Unvisited", ansi_color: :green)

    Logger.info("Create fake users and their listening history...", ansi_color: :green)

    genre_categories = get_genre_categories()

    Enum.each(genre_categories, fn category ->
      # 2800 users per group of genres
      1..2800
      |> Stream.chunk_every(@chunk_size)
      |> Enum.map(&process_users(&1, category))
    end)

    Logger.info("Finished generating the listening history", ansi_color: :green)
  end

  defp process_users(users, category) do
    Enum.each(users, fn _user ->
      max_percentage = Enum.at(@max_percentage_for_a_genre, :rand.uniform(10))
      yob = Enum.at(@birth_date, :rand.uniform(34))

      listening_history =
        calculate_genre_distribution(max_percentage, category, @listening_threshold_minutes)

      name_suffix = Ecto.UUID.generate()
      name = "User_#{name_suffix}"

      CreateUserWorker.enqueue(%{
        "name" => name,
        "yob" => yob,
        "listening_history" => listening_history
      })
    end)
  end

  defp calculate_genre_distribution(max_percentage, category, minutes_per_user) do
    [lead_genre | other_genres] = Enum.shuffle(category)
    genre_count = Enum.count(category)
    lead_genre_minutes = div(minutes_per_user, 100) * max_percentage

    other_genres_minutes =
      Enum.map(2..genre_count, fn rank ->
        coefficient = 1 / :math.pow(rank, @zipf_exponent)

        coefficient * lead_genre_minutes
      end)

    other_genres_minutes
    |> Enum.with_index()
    |> Enum.into(%{lead_genre => lead_genre_minutes}, fn {minutes, index} ->
      genre = Enum.at(other_genres, index)

      truncated_minutes =
        minutes
        |> :math.floor()
        |> trunc()

      {genre, truncated_minutes}
    end)
  end

  defp prepare_songs_for_traversal do
    Boltx.query!(
      Bolt,
      """
      MATCH (s:Song)
      WHERE NOT exists((s)<-[:LISTENED_TO]-())
      SET s:UnvisitedSong
      """
    )
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
