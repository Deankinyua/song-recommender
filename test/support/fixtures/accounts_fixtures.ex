defmodule SongRecommender.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SongRecommender.Accounts` context.
  """

  alias SongRecommender.Accounts
  alias SongRecommender.Accounts.User

  @doc """
  Create a user.
  """
  @spec user_fixture(map()) :: User.t()
  def user_fixture(attrs \\ %{}) do
    unique_id = System.unique_integer([:positive])

    {:ok, user} =
      attrs
      |> Enum.into(%{
        name: "some_name#{unique_id}",
        yob: 2000
      })
      |> Accounts.register_user()

    user
  end
end
