defmodule AddGraph do
  require Logger

  @chunk_size 30
  @genres Application.compile_env!(:song_recommender, :genres)

  NimbleCSV.define(MyCSV, separator: ",", escape: "\"")

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
    |> Enum.map(&process_chunk(&1))
  end

  defp process_chunk(chunk), do: Enum.map(chunk, &add_song_details(&1))

  defp add_song_details(song_details) do
    [[artist, track_name, track_id, popularity, year_released, genre, duration_ms]] =
      song_details
      |> String.trim()
      |> MyCSV.parse_string(skip_headers: false)

    Boltx.query!(
      Bolt,
      """
      MERGE (s:Song {id: $track_id})
      ON CREATE SET s.duration_ms = $duration_ms,
                    s.popularity = $popularity,
                    s.released = $year_released,
                    s.name = $track_name
      OPTIONAL MATCH (s)-[:BELONGS_TO]->(genre:Genre)
      CALL (*) {
        WHEN genre IS NULL THEN {
          MATCH (g:Genre {name: $genre})
          MERGE (a:Artist {name: $artist})
          MERGE (a)-[:SANG]->(s)-[:BELONGS_TO]->(g)
          RETURN s.name AS song
        }
      }
      RETURN song
      """,
      %{
        artist: artist,
        duration_ms: duration_ms,
        genre: genre,
        popularity: String.to_integer(popularity),
        track_id: track_id,
        track_name: track_name,
        year_released: String.to_integer(year_released)
      }
    )
  end

  defp fetch_csv_file(_opts),
    do: Application.fetch_env!(:song_recommender, :spotify_data_file_path)
end

AddGraph.start()
