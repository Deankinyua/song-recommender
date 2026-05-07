defmodule AddGraph do
  @moduledoc """
  This is the third script that you should run.
  It Add songs, genres and artists from the spotify_data csv file.
  """

  require Logger

  @chunk_size 30
  @genres Application.compile_env!(:song_recommender, :genres)

  NimbleCSV.define(SpotifyDataCSV, separator: ",", escape: "\"")

  def start do
    Logger.info("Adding genres ...", ansi_color: :green)
    create_genres()
    Logger.info("Finished adding genres", ansi_color: :green)

    Logger.info("Adding songs, linking to genres and artists ...", ansi_color: :green)
    process_song_details()
    Logger.info("Finished adding songs", ansi_color: :green)
  end

  defp create_genres do
    for genre <- @genres do
      Boltx.query!(
        Bolt,
        """

        MERGE (g:Genre {name: $genre})

        """,
        %{genre: genre}
      )
    end
  end

  defp process_song_details do
    []
    |> fetch_csv_file()
    |> File.stream!()
    |> Stream.chunk_every(@chunk_size)
    |> Enum.map(&process_songs(&1))
  end

  defp process_songs(songs), do: Enum.map(songs, &add_song_details(&1))

  defp add_song_details(song_details) do
    [[artist, track_name, track_id, popularity, year_released, genre, duration_ms]] =
      song_details
      |> String.trim()
      |> SpotifyDataCSV.parse_string(skip_headers: false)

    Boltx.query!(
      Bolt,
      """
      MERGE (s:Song {id: $track_id})
      ON CREATE SET s.duration_ms = $duration_ms,
                    s.popularity = $popularity,
                    s.released = $year_released,
                    s.name = $track_name,
                    s.normalized_name = $track_normalized_name
      OPTIONAL MATCH (s)-[:BELONGS_TO]->(genre:Genre)
      CALL (*) {
        WHEN genre IS NULL THEN {
          MATCH (g:Genre {name: $genre})
          MERGE (a:Artist {name: $artist_name})
          ON CREATE SET a.normalized_name = $artist_normalized_name,
                        a.monthlyListeners = 0
          MERGE (a)-[:SANG]->(s)-[:BELONGS_TO]->(g)
        }
      }
      RETURN s.name AS song
      """,
      %{
        artist_name: artist,
        artist_normalized_name: String.downcase(artist),
        duration_ms: String.to_integer(duration_ms),
        genre: genre,
        popularity: String.to_integer(popularity),
        track_id: track_id,
        track_name: track_name,
        track_normalized_name: String.downcase(track_name),
        year_released: String.to_integer(year_released)
      }
    )
  end

  defp fetch_csv_file(_opts),
    do: Application.fetch_env!(:song_recommender, :spotify_data_file_path)
end

AddGraph.start()
