defmodule SongRecommender.Genres do
  @moduledoc """
  Utilities to manage genres
  """

  @type bolt_response :: Boltx.Response.t()
  @type genre :: String.t()
  @type genre_and_listening_time :: [genre() | listening_time()]
  @type listening_time :: integer()
  @type username :: String.t()

  @doc """
  Gets a user's genres. Returns an empty list if the user hasn't
  preferred any genres.

  ## Examples

      iex> get_user_genres("Dean")
        ["acoustic", "hip-hop"]

  """

  @spec get_user_genres(username()) :: [genre()]
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
  Creates a PREFERS relationship between a user and some genres

  ## Examples

      iex> prefer_genres("Dean", ["hip-hop"])
        %User{genres: ["hip-hop"], name: "Dean"}

  """

  @spec prefer_genres(username(), [genre()]) :: [genre()]
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
  Creates a LISTENED_TO_GENRE relationship between a user and some genres.
  This function has a deeper purpose. It can be used in the wrapped feature
  and also checking the totalListeningTime for the user computed by going
  through all the genres of music the user has listened to.

  ## Examples

      iex> listen_to_genres("Dean", [ ["hip-hop", 3213], ["house", 1293] ])
       %Boltx.Response{}

  """

  @spec listen_to_genres(username(), [genre_and_listening_time()]) :: bolt_response()
  def listen_to_genres(username, genres_and_listening_times) do
    Boltx.query!(
      Bolt,
      """
      MATCH (u:User {name: $name})
      UNWIND $genres_and_listening_times AS genre_and_listening_time
      WITH u, genre_and_listening_time[0] AS genre, genre_and_listening_time[1] AS durationListened
      MATCH (g:Genre {name: genre})
      MERGE (u)-[lg:LISTENED_TO_GENRE]->(g)
      ON CREATE SET lg.totalListeningTimeMs = durationListened
      ON MATCH SET lg.totalListeningTimeMs = lg.totalListeningTimeMs + durationListened
      """,
      %{name: username, genres_and_listening_times: genres_and_listening_times}
    )
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
      RETURN sum(lg.totalListeningTimeMs) AS lifetime_listening_ms
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
