defmodule SongRecommender.Genres do
  @moduledoc """
  Utilities to manage genres
  """

  alias SongRecommender.Accounts.User

  @type bolt_response :: Boltx.Response.t()
  @type genre :: String.t()
  @type user :: User.t()
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
        """,
        %{name: username}
      )

    if Enum.empty?(genres) do
      []
    else
      Enum.map(genres, &process_genre(&1))
    end
  end

  @doc """
  Creates a PREFERS relationship between a user and some genres

  ## Examples

      iex> get_user_genres("Dean")
        ["acoustic", "hip-hop"]

  """

  @spec prefer_genres(username(), [genre()]) :: user()
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
      RETURN u { .name } as user,
      collect(DISTINCT g.name) AS preferred_genres
      """,
      %{genres: genres, name: username}
    )
    |> Boltx.Response.first()
    |> process_preferred_genres()
  end

  defp process_preferred_genres(%{"preferred_genres" => genres, "user" => %{"name" => name}}),
    do: %User{name: name, genres: genres}

  defp process_genre(%{"genre" => name}), do: name
end
