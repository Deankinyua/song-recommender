defmodule SongRecommender.Accounts do
  @moduledoc """
  Simple user accounts backed by Neo4j
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

      iex> register_user(%{"name" => "Dean"})
        {:ok, %User{name: "Dean"}}

  """

  @spec register_user(attrs()) :: {:ok, user()} | {:error, changeset()}
  def register_user(attrs) do
    changeset = change_user_registration(%User{}, attrs)

    if changeset.valid? do
      %{name: username} = changeset.changes

      %{"user" => %{"name" => name}} = create_user(username)

      {:ok, %User{name: name}}
    else
      {:error, changeset}
    end
  end

  defp create_user(name) do
    Bolt
    |> Boltx.query!(
      """
      MERGE (u:User {name: $name})
      RETURN u { .name } as user
      """,
      %{name: name}
    )
    |> Boltx.Response.first()
  end

  @doc """
  Returns a user with the given name.

  ## Examples

      iex> get_user!("Dean")
        %User{name: "Dean"}

  """

  @spec get_user!(name()) :: user() | nil
  def get_user!(name) do
    case get_user_by_name(name) do
      nil ->
        nil

      %{"user" => %{"name" => name}} ->
        %User{name: name}
    end
  end

  defp get_user_by_name(name) when is_binary(name) do
    Bolt
    |> Boltx.query!(
      """
      MATCH (u:User {name: $name})
      RETURN u { .name} as user
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
    Boltx.query!(
      Bolt,
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
    case get_user_by_token(token) do
      nil -> nil
      {:ok, user} -> user
    end
  end

  defp get_user_by_token(token) do
    case user_by_token(token) do
      nil ->
        nil

      %{"user" => %{"name" => name}} ->
        {:ok, %User{name: name}}
    end
  end

  defp user_by_token(token) do
    Bolt
    |> Boltx.query!(
      """
      MATCH (u:User)
      WHERE u.token = $token AND
      u.tokenInsertedAt >= datetime() - duration({days: 60})
      RETURN u { .name } as user
      """,
      %{token: token}
    )
    |> Boltx.Response.first()
  end

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
