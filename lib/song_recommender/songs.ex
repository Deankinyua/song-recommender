defmodule SongRecommender.Songs do
  @moduledoc """
  Tracks how users listen to songs
  """

  @type bolt_response :: Boltx.Response.t()
  @type genre :: String.t()
  @type username :: String.t()

  @doc """
  Listen's to the most popular song from a given genre.
  It first finds songs the user hasn't listened to already.
  Finding one, it adds the LISTENED_TO relationship to it with the
  duration_played_ms property being the song duration.
  After exhausting all songs it will retrieve only the songs that were played less
  than 3 times. Then, it will update the duration_played_ms property
  each time setting it to the former value + the song duration.
  """

  @spec listen_from_genre(username(), genre()) :: bolt_response()
  def listen_from_genre(username, genre) do
    Boltx.query!(
      Bolt,
      """
      MATCH (user:User {name: $username})
      MATCH (genre:Genre {name: $genre})
      OPTIONAL MATCH (song:Song)-[:BELONGS_TO]->(genre)
      WHERE NOT exists( (user)-[:LISTENED_TO]->(song) )
      WITH song, user, genre
        ORDER BY song.popularity DESC
        LIMIT 1
      CALL (*) {
        WHEN song IS NULL THEN {
          MATCH (user)-[l:LISTENED_TO]->(listenedToSong:Song)-[:BELONGS_TO]->(genre)
          WHERE l.duration_played_ms < listenedToSong.duration_ms * 3
          RETURN listenedToSong AS finalSong
          ORDER BY finalSong.popularity DESC
          LIMIT 1
        }
        WHEN song IS NOT NULL THEN {
          RETURN song AS finalSong
        }
      }
      MERGE (user)-[lt:LISTENED_TO]->(finalSong)
      ON CREATE
      SET lt.duration_played_ms = finalSong.duration_ms
      ON MATCH
      SET lt.duration_played_ms = lt.duration_played_ms + finalSong.duration_ms
      """,
      %{
        genre: genre,
        username: username
      }
    )
  end
end
