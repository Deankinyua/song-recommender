defmodule SongRecommender.Artists do
  @moduledoc """
  Utilities to manage artists
  """

  import Ecto.Changeset, only: [apply_action!: 2]

  alias SongRecommender.Artists.Artist
  alias SongRecommender.Songs.Song

  @type artist :: Artist.t()
  @type artist_name :: String.t()
  @type attrs :: map()
  @type bolt_response :: Boltx.Response.t()
  @type song :: Song.t()
  @type username :: String.t()

  @doc """
  Checks if a user is following a particular artist
  """

  @spec check_following_status(username(), artist_name()) :: boolean()
  def check_following_status(username, artist_name) do
    Bolt
    |> Boltx.query!(
      """
      MATCH (u:User {name: $username}), (a:Artist {name: $artist_name})
      RETURN EXISTS { (u)-[:FOLLOWS]->(a) } AS following
      """,
      %{username: username, artist_name: artist_name}
    )
    |> Boltx.Response.first()
    |> return_following_status()
  end

  @doc """
  Checks if the user follows the artist who produced a particular
  song and adds the following status to the song.
  """

  @spec set_artist_following_status(song(), username()) :: song()
  def set_artist_following_status(%{artist: artist} = song, username) do
    following_artist? = check_following_status(username, artist.name)
    updated_artist = Map.replace!(artist, :following, following_artist?)
    Map.replace!(song, :artist, updated_artist)
  end

  @doc """
  Follows an artist
  """

  @spec follow_artist(username(), artist_name()) :: bolt_response()
  def follow_artist(username, artist_name) do
    Boltx.query!(
      Bolt,
      """
      MATCH (u:User {name: $username}), (a:Artist {name: $artist_name})
      MERGE (u)-[:FOLLOWS]->(a)
      """,
      %{username: username, artist_name: artist_name}
    )
  end

  @doc """
  Unfollows an artist
  """

  @spec unfollow_artist(username(), artist_name()) :: bolt_response()
  def unfollow_artist(username, artist_name) do
    Boltx.query!(
      Bolt,
      """
      MATCH (u:User {name: $username})-[f:FOLLOWS]->(a:Artist {name: $artist_name})
      DELETE f
      """,
      %{username: username, artist_name: artist_name}
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

      iex> get_followed_artists("Dean")
        ["Drake", "Taylor Swift"]

  """

  @spec get_followed_artists(username()) :: [artist_name()]
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

  @doc """
  Updates an artist struct with new attributes
  """

  @spec populate_artist(artist(), attrs()) :: artist()
  def populate_artist(%Artist{} = artist, attrs) do
    artist
    |> Artist.changeset(attrs)
    |> apply_action!(:update)
  end

  defp process_artist(%{"artist" => name}), do: name

  defp return_following_status(%{"following" => following}), do: following
end
