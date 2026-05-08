defmodule SongRecommender.AccountsTest do
  use SongRecommender.DataCase, async: false

  import SongRecommender.AccountsFixtures

  alias SongRecommender.Accounts
  alias SongRecommender.Accounts.User

  @invalid_user_attrs %{name: nil}
  @valid_user_attrs %{name: "Marion"}

  defp create_user_and_token(_attrs) do
    user = user_fixture()
    token = Accounts.generate_user_session_token(user.name)
    %{token: token, user: user}
  end

  describe "register_user/1" do
    test "with valid data, creates a user" do
      {:ok, %User{} = user} = Accounts.register_user(@valid_user_attrs)

      assert user.name == "Marion"
    end

    test "with invalid data, returns error changeset" do
      assert {:error, %Ecto.Changeset{} = changeset} = Accounts.register_user(@invalid_user_attrs)

      assert "can't be blank" in errors_on(changeset).name
    end
  end

  describe "get_user!/1" do
    setup [:create_user_and_token]

    test "returns a user if they exist", %{user: user} do
      retrieved_user = Accounts.get_user!(user.name)
      assert retrieved_user.name == user.name
    end

    test "returns nil for a user that doesn't exist" do
      refute Accounts.get_user!("nonexistentuser")
    end
  end

  describe "generate_user_session_token/1" do
    setup [:create_user_and_token]

    test "adds an auth token for a user", %{user: user} do
      token = Accounts.generate_user_session_token(user.name)
      retrieved_user = Accounts.get_user_by_session_token(token)
      assert retrieved_user.name == user.name
    end
  end

  describe "get_user_by_session_token/1" do
    setup [:create_user_and_token]

    test "returns a user if the token is valid", %{token: token, user: user} do
      retrieved_user = Accounts.get_user_by_session_token(token)
      assert retrieved_user.name == user.name
    end

    test "returns nil when the token is invalid" do
      refute Accounts.get_user_by_session_token("2ZWlPOoWh0626oTaHrnl2a")
    end
  end

  describe "delete_user_session_token/1" do
    setup [:create_user_and_token]

    test "deletes a user session token", %{token: token} do
      Accounts.delete_user_session_token(token)
      refute Accounts.get_user_by_session_token(token)
    end
  end
end
