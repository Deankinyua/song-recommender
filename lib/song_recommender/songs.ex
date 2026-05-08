defmodule SongRecommender.Songs do
  @moduledoc """
  Tracks how users listen to songs
  """

  alias SongRecommender.Songs.Song

  @type bolt_response :: Boltx.Response.t()
  @type genre :: String.t()
  @type listening_duration :: integer()
  @type song :: Song.t()
  @type song_id :: String.t()
  @type username :: String.t()

  @doc """
  Returns a song with its details
  """
  @spec get_song!(song_id()) :: song() | nil
  def get_song!(song_id) do
    case song_by_id(song_id) do
      nil ->
        nil

      %{
        "song" => %{
          "duration_ms" => duration_ms,
          "id" => id,
          "name" => name,
          "popularity" => popularity,
          "released" => released
        }
      } ->
        %Song{
          duration_ms: duration_ms,
          id: id,
          name: name,
          popularity: popularity,
          released: released
        }
    end
  end

  defp song_by_id(song_id) do
    Bolt
    |> Boltx.query!(
      """
      MATCH (s:Song {id: $song_id})
      RETURN s { .* } as song
      """,
      %{song_id: song_id}
    )
    |> Boltx.Response.first()
  end

  @doc """
  Returns the duration a user has listened to a particualar song
  """
  @spec get_song_listening_time(song_id(), username()) :: listening_duration()
  def get_song_listening_time(song_id, username) do
    case get_listening_time(song_id, username) do
      nil ->
        nil

      %{"listening_time" => listening_time} ->
        listening_time
    end
  end

  defp get_listening_time(song_id, username) do
    Bolt
    |> Boltx.query!(
      """
      MATCH (:Song {id: $song_id})<-[lt:LISTENED_TO]-(:User {name: $name})
      RETURN lt.duration_played_ms AS listening_time
      """,
      %{song_id: song_id, name: username}
    )
    |> Boltx.Response.first()
  end

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
      ON CREATE SET lt.duration_played_ms = finalSong.duration_ms
      ON MATCH SET lt.duration_played_ms = lt.duration_played_ms + finalSong.duration_ms
      SET lt.lastPlayedDate = datetime()
      """,
      %{
        genre: genre,
        username: username
      }
    )
  end
end
