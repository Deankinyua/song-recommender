defmodule SongRecommender.Songs do
  @moduledoc """
  Tracks how users listen to songs
  """

  alias SongRecommender.Artists.Artist
  alias SongRecommender.Genres.Genre
  alias SongRecommender.Songs.Song

  @type bolt_response :: Boltx.Response.t()
  @type genre :: String.t()
  @type listening_duration :: integer()
  @type song :: Song.t()
  @type song_id :: String.t()
  @type taste_profile :: map()
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
          "durationMs" => duration_ms,
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
      RETURN lt.durationPlayedMs AS listening_time
      """,
      %{song_id: song_id, name: username}
    )
    |> Boltx.Response.first()
  end

  @doc """
  Listen's to the most popular song from a given genre.
  It first finds songs the user hasn't listened to already.
  Finding one, it adds the LISTENED_TO relationship to it with the
  durationPlayedMs property being the song duration.
  After exhausting all songs it will retrieve only the songs that were played less
  than 3 times. Then, it will update the durationPlayedMs property
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
      WHERE NOT EXISTS { (user)-[:LISTENED_TO]->(song) }
      WITH song, user, genre
        ORDER BY song.popularity DESC
        LIMIT 1
      CALL (*) {
        WHEN song IS NULL THEN {
          MATCH (user)-[l:LISTENED_TO]->(listenedToSong:Song)-[:BELONGS_TO]->(genre)
          WHERE l.durationPlayedMs < listenedToSong.durationMs * 3
          RETURN listenedToSong AS finalSong
          ORDER BY finalSong.popularity DESC
          LIMIT 1
        }
        ELSE {
          RETURN song AS finalSong
        }
      }
      MERGE (user)-[lt:LISTENED_TO]->(finalSong)
      ON CREATE SET lt.durationPlayedMs = finalSong.durationMs
      ON MATCH SET lt.durationPlayedMs = lt.durationPlayedMs + finalSong.durationMs
      SET lt.lastPlayedDate = datetime()
      """,
      %{
        genre: genre,
        username: username
      }
    )
  end

  @doc """
  Gets songs belonging to some genres and some sang by some artists
  """
  @spec get_songs_with_genre_based_strategy(taste_profile()) :: [song()]
  def get_songs_with_genre_based_strategy(%{artists: artists, genres: genres} = _taste_profile) do
    %{nodes: artist_names, limit: artists_song_limit} = artists
    %{nodes: genre_names, limit: genres_song_limit} = genres

    %Boltx.Response{results: song_data} =
      Boltx.query!(
        Bolt,
        """
        CALL () {

          UNWIND $genres AS genre
          WITH genre
          CALL (*) {
            MATCH (a:Artist)-[:SANG]->(s:Song)-[:BELONGS_TO]->(g:Genre {name: genre})
            RETURN s AS song, a AS artist, g.name AS genreName
            ORDER BY s.popularity DESC
            LIMIT $genres_song_limit
          }
          RETURN song, artist, genreName

        UNION

          UNWIND $artists AS artistName
          WITH artistName
          CALL (*) {
            MATCH (a:Artist {name: artistName})-[:SANG]->(s:Song)-[:BELONGS_TO]->(g:Genre)
            RETURN s AS song, a AS artist, g.name AS genreName
            ORDER BY s.popularity DESC
            LIMIT $artists_song_limit
          }
          RETURN song, artist, genreName

        }

        RETURN song { .id, .name, .durationMs, .released },
               artist { .name, .monthlyListeners },
               genreName
        """,
        %{
          artists: artist_names,
          artists_song_limit: artists_song_limit,
          genres: genre_names,
          genres_song_limit: genres_song_limit
        }
      )

    Enum.map(song_data, &process_song_data(&1))
  end

  defp process_song_data(%{
         "song" => %{
           "durationMs" => duration_ms,
           "id" => song_id,
           "name" => song_name,
           "released" => released
         },
         "artist" => %{
           "monthlyListeners" => monthly_listeners,
           "name" => artist_name
         },
         "genreName" => genre
       }) do
    genre = %Genre{name: genre}
    artist = %Artist{id: Ecto.UUID.generate(), name: artist_name, listeners: monthly_listeners}

    %Song{
      artist: artist,
      duration_ms: duration_ms,
      genre: genre,
      id: song_id,
      name: song_name,
      released: released
    }
  end
end
