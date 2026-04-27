defmodule SongRecommenderWeb.UserSessionController do
  @moduledoc """
  Handles user log in and log out
  """

  use SongRecommenderWeb, :controller

  alias SongRecommender.Accounts
  alias SongRecommenderWeb.UserAuth

  @type conn :: Plug.Conn.t()
  @type params :: map()

  @spec log_out(conn(), params()) :: conn()
  def log_out(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end

  @spec create(conn(), params()) :: conn()
  def create(conn, %{"_action" => "registered"} = params),
    do: create(conn, params, "Account created successfully!")

  def create(conn, params), do: create(conn, params, "Welcome back!")

  defp create(conn, %{"user" => %{"name" => name} = user_params}, info) do
    user = Accounts.get_user!(name)

    if user do
      conn
      |> put_flash(:info, info)
      |> UserAuth.log_in_user(user, user_params)
    else
      conn
      |> put_flash(:error, "User #{name} doesn't exist")
      |> redirect(to: ~p"/sign-in")
    end
  end
end
