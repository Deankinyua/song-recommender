defmodule SongRecommender.Genres do
  @moduledoc """
  Utilities to manage genres
  """

  @type genre_name :: String.t()
  @type listening_time :: integer()
  @type username :: String.t()

  @doc """
  Gets a user's genres. Returns an empty list if the user hasn't
  preferred any genres.

  ## Examples

      iex> get_user_genres("Dean")
        ["acoustic", "hip-hop"]

  """

  @spec get_user_genres(username()) :: [genre_name()]
  def get_user_genres(username) do
    %Boltx.Response{results: genres} =
      Boltx.query!(
        Bolt,
        """
        MATCH (u:User {name: $name})-[:PREFERS]->(g:Genre)
        RETURN g.name AS genre
        LIMIT 20
        """,
        %{name: username}
      )

    if Enum.empty?(genres) do
      []
    else
      genres
      |> Enum.map(&process_genre(&1))
      |> Enum.shuffle()
      |> Enum.take(5)
    end
  end

  @doc """
  Gets the favorite genres of a particular user. Used when the
  user has spent at least an hour listening to songs.

  ## Examples

      iex> get_favorite_genres("Dean")
        ["acoustic", "hip-hop"]

  """

  @spec get_favorite_genres(username()) :: [genre_name()]
  def get_favorite_genres(username) do
    %Boltx.Response{results: genres} =
      Boltx.query!(
        Bolt,
        """
        MATCH (u:User {name: $name})
        CALL (u) {
          MATCH (u)-[lg:LISTENED_TO_GENRE]->(g:Genre)
          RETURN g AS theGenre
          ORDER BY lg.totalDurationPlayedMs DESC
          LIMIT 5

        UNION

          MATCH (u)-[:PREFERS]->(g:Genre)
          RETURN g AS theGenre
          SKIP $randomizer
          LIMIT 2

        }

        RETURN theGenre.name AS genre
        """,
        %{name: username, randomizer: :rand.uniform(5)}
      )

    if Enum.empty?(genres) do
      []
    else
      genres
      |> Enum.map(&process_genre(&1))
      |> Enum.shuffle()
    end
  end

  @doc """
  Creates a PREFERS relationship between a user and some genres

  ## Examples

      iex> prefer_genres("Dean", ["hip-hop"])
        ["hip-hop"]

  """

  @spec prefer_genres(username(), [genre_name()]) :: [genre_name()]
  def prefer_genres(username, genres) do
    Bolt
    |> Boltx.query!(
      """
      MATCH (u:User {name: $name})
      OPTIONAL MATCH (u)-[r:PREFERS]->()
      DELETE r
      WITH u
      UNWIND $genres AS genre
      MATCH (g:Genre {name: genre})
      MERGE (u)-[:PREFERS]->(g)
      RETURN collect(DISTINCT g.name) AS preferred_genres
      """,
      %{genres: genres, name: username}
    )
    |> Boltx.Response.first()
    |> process_preferred_genres()
  end

  @doc """
  Calculates the totalListeningTime in milliseconds.

  ## Examples

      iex> calculate_total_listening_time("Dean")
      0

  """

  @spec calculate_total_listening_time(username()) :: listening_time()
  def calculate_total_listening_time(username) do
    Bolt
    |> Boltx.query!(
      """
      MATCH (u:User {name: $name})-[lg:LISTENED_TO_GENRE]->(g:Genre)
      RETURN sum(lg.totalDurationPlayedMs) AS lifetime_listening_ms
      """,
      %{name: username}
    )
    |> Boltx.Response.first()
    |> process_listening_time()
  end

  defp process_listening_time(%{"lifetime_listening_ms" => total_listening_time}),
    do: total_listening_time

  defp process_preferred_genres(%{"preferred_genres" => genres}), do: genres

  defp process_genre(%{"genre" => name}), do: name
end
