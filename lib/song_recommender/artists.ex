defmodule SongRecommender.Artists do
  @moduledoc """
  Utilities to manage artists
  """

  alias SongRecommender.Artists.Artist
  alias SongRecommender.Genres.Genre
  alias SongRecommender.Songs.Song

  @type artist :: String.t()
  @type bolt_response :: Boltx.Response.t()
  @type limit :: integer()
  @type song :: Song.t()
  @type username :: String.t()

  @doc """
  Follows an artist
  """

  @spec follow_artist(username(), artist()) :: bolt_response()
  def follow_artist(username, artist) do
    Boltx.query!(
      Bolt,
      """
      MATCH (u:User {name: $username}), (a:Artist {name: $artist_name})
      MERGE (u)-[:FOLLOWS]->(a)
      """,
      %{username: username, artist_name: artist}
    )
  end

  @doc """
  If this was in production, you would filter with the LISTENED_TO property
  `lastPlayedDate` to find only the songs that were listened to over the
  past month.You would add a WHERE clause:

  `WHERE listened.lastPlayedDate >= datetime() - duration({days: 30})`
  """

  @spec update_monthly_listeners :: bolt_response()
  def update_monthly_listeners do
    Boltx.query!(
      Bolt,
      """
      MATCH (artist:Artist)-[SANG]->(:Song)<-[listened:LISTENED_TO]-(:User)
      WITH artist, count(listened) AS listenerCount
      SET artist.monthlyListeners = listenerCount
      """
    )
  end

  @doc """
  Gets the artists a user has followed. Returns an empty list if the user hasn't
  followed any artists.

  ## Examples

      iex> get_user_genres("Dean")
        ["Drake", "Taylor Swift"]

  """

  @spec get_followed_artists(username()) :: [artist()]
  def get_followed_artists(username) do
    %Boltx.Response{results: artists} =
      Boltx.query!(
        Bolt,
        """
        MATCH (u:User {name: $name})-[:FOLLOWS]->(a:Artist)
        RETURN a.name AS artist
        ORDER BY a.monthlyListeners DESC
        LIMIT 30
        """,
        %{name: username}
      )

    if Enum.empty?(artists) do
      []
    else
      artists
      |> Enum.map(&process_artist(&1))
      |> Enum.shuffle()
      |> Enum.take(5)
    end
  end

  @spec get_songs_from_artists([artist()], limit()) :: [song()]
  def get_songs_from_artists(artists, limit) do
    %Boltx.Response{results: song_data} =
      Boltx.query!(
        Bolt,
        """
        UNWIND $artists AS artist
        WITH artist
        CALL (*) {
          MATCH (a:Artist {name: artist})-[:SANG]->(s:Song)-[:BELONGS_TO]->(g:Genre)
          RETURN s AS song, a, g.name AS genreName
          ORDER BY s.popularity DESC
          LIMIT $limit
        }
        RETURN song { .id, .name, .durationMs, .released },
               a { .name, .monthlyListeners },
               genreName
        """,
        %{artists: artists, limit: limit}
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
         "a" => %{
           "monthlyListeners" => monthly_listeners,
           "name" => artist_name
         },
         "genreName" => genre
       }) do
    genre = %Genre{name: genre}
    artist = %Artist{name: artist_name, listeners: monthly_listeners}

    %Song{
      artist: artist,
      duration_ms: duration_ms,
      genre: genre,
      id: song_id,
      name: song_name,
      released: released
    }
  end

  defp process_artist(%{"artist" => name}), do: name
end
