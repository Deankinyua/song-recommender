defmodule SongRecommender.Songs do
  @moduledoc """
  Tracks how users listen to songs
  """

  @type bolt_response :: Boltx.Response.t()
  @type genre :: String.t()
  @type username :: String.t()

  @doc """
  `LISTEN_TO` to one song from a given genre
  It first checks if it can a find a song that no one has listened_to (UnvisitedSong)
  If it finds one it marks it as LISTENED_TO by removing the UnvisitedSong label
  then returns it for processing. If it can't find one it retrieves one song
  from the genre (regardless of whether it has been listened to already) and returns it
  It then marks that the user listened to that song for a specific duration of time
  """

  @spec listen_from_genre(username(), genre(), integer()) :: bolt_response()
  def listen_from_genre(username, genre, duration_played_ms) do
    Bolt
    |> Boltx.query!(
      """
      MATCH (u:User {name: $username})
      MATCH (g:Genre {name: $genre})
      OPTIONAL MATCH (s:UnvisitedSong)-[:BELONGS_TO]->(g)
      WITH s, u, g LIMIT 1
      CALL (*) {
        WHEN s IS NULL THEN {
          MATCH (song:Song)-[:BELONGS_TO]->(g)
          RETURN song LIMIT 1
        }
        WHEN s IS NOT NULL THEN {
          REMOVE s:UnvisitedSong
          RETURN s AS song
        }
      }
      MERGE (u)-[:LISTENED_TO {duration_played_ms: $duration_played_ms}]->(song)
      """,
      %{
        duration_played_ms: duration_played_ms,
        genre: genre,
        username: username
      }
    )
    |> Boltx.Response.first()
  end
end
