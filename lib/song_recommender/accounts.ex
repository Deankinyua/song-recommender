defmodule SongRecommender.Accounts do
  @moduledoc """
    Simple user accounts backed by neo4j
  """

  alias SongRecommender.Accounts.User

  @type attrs :: map()
  @type bolt_response :: Boltx.Response.t()
  @type changeset :: Ecto.Changeset.t()
  @type name :: String.t()
  @type token :: binary()
  @type user :: User.t()

  @rand_size 32

  @doc """
  Registers a user. Returns an error if the user already exists

  ## Examples

      iex> register_user(%{"name" => "Dean", "yob" => 2003})
        {:ok, %User{genres: [], name: "Dean", yob: "2003"}}

  """

  @spec register_user(attrs()) :: {:ok, user()} | {:error, changeset()}
  def register_user(attrs) do
    changeset = change_user_registration(%User{}, attrs)

    if changeset.valid? do
      %{name: username, yob: user_yob} = changeset.changes

      %{"u" => %Boltx.Types.Node{properties: %{"name" => name, "yob" => yob}}} =
        create_user(username, user_yob)

      genres = get_user_genres(name)
      {:ok, %User{genres: genres, name: name, yob: yob}}
    else
      {:error, changeset}
    end
  end

  def create_user(name, yob) do
    Bolt
    |> Boltx.query!(
      """
      MERGE (u:User {name: $name})
      ON CREATE SET u.yob = $yob
      RETURN u
      """,
      %{
        name: name,
        yob: yob
      }
    )
    |> Boltx.Response.first()
  end

  @doc """
  Returns a user with the given name.

  ## Examples

      iex> get_user!("Dean")
        %User{genres: [], name: "Dean", yob: "2003"}

  """

  @spec get_user!(name()) :: user() | nil
  def get_user!(name) do
    case get_user_by_name(name) do
      nil ->
        nil

      %{
        "u" => %Boltx.Types.Node{
          properties: %{
            "name" => name,
            "yob" => yob
          }
        }
      } ->
        %User{name: name, yob: yob}
    end
  end

  defp get_user_by_name(name) when is_binary(name) do
    Bolt
    |> Boltx.query!(
      """
      MATCH (u:User {name: $name})
      RETURN u
      """,
      %{name: name}
    )
    |> Boltx.Response.first()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user_registration(user)
      %Ecto.Changeset{data: %User{}}

  """

  @spec change_user_registration(user(), attrs()) :: changeset()
  def change_user_registration(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  @doc """
  Generates a session token.
  """

  @spec generate_user_session_token(name()) :: token()
  def generate_user_session_token(username) do
    token = :crypto.strong_rand_bytes(@rand_size)
    store_token(username, token)
    token
  end

  defp store_token(name, token) do
    Bolt
    |> Boltx.query!(
      """
      MATCH (u:User {name: $name})
      SET u.token = $token, u.tokenInsertedAt = datetime()
      """,
      %{name: name, token: token}
    )
  end

  @doc """
  Gets the user by the session token. Ensures the token has not expired.
  """
  @spec get_user_by_session_token(name()) :: user() | nil
  def get_user_by_session_token(token) do
    with {:ok, user} <- get_user_by_token(token),
         genres <- get_user_genres(user.name) do
      Map.put(user, :genres, genres)
    else
      nil ->
        nil
    end
  end

  defp get_user_by_token(token) do
    case user_by_token(token) do
      nil ->
        nil

      %{
        "u" => %Boltx.Types.Node{
          properties: %{
            "name" => name,
            "yob" => yob
          }
        }
      } ->
        {:ok, %User{name: name, yob: yob}}
    end
  end

  defp user_by_token(token) do
    Bolt
    |> Boltx.query!(
      """
      MATCH (u:User)
      WHERE u.token = $token AND
      u.tokenInsertedAt >= datetime() - duration({days: 60})
      RETURN u
      """,
      %{token: token}
    )
    |> Boltx.Response.first()
  end

  defp get_user_genres(username) do
    %Boltx.Response{results: genres} =
      Boltx.query!(
        Bolt,
        """
        MATCH (u:User {name: $name})-[:PREFERS]->(g:Genre)
        RETURN g
        """,
        %{name: username}
      )

    if Enum.empty?(genres) do
      []
    else
      Enum.map(genres, &process_genre(&1))
    end
  end

  defp process_genre(%{
         "g" => %Boltx.Types.Node{
           properties: %{"name" => name}
         }
       }),
       do: name

  @doc """
  Deletes a user token, effectively logging out the user
  """

  @spec delete_user_session_token(token()) :: bolt_response()
  def delete_user_session_token(token) do
    Boltx.query!(
      Bolt,
      """
      MATCH (u:User)
      WHERE u.token = $token
      SET u.token = null
      """,
      %{token: token}
    )
  end
end
