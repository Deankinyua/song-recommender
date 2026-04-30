defmodule SongRecommender.AccountsTest do
  use SongRecommender.DataCase, async: true

  # import SongRecommender.AccountsFixtures

  alias SongRecommender.Accounts
  alias SongRecommender.Accounts.User

  @valid_attrs %{
    "name" => "Marion",
    "yob" => 1996
  }

  # defp create_user_and_token(_attrs) do
  #   user = user_fixture()
  #   token = Accounts.generate_user_session_token(user)
  #   %{user: user, token: token}
  # end

  describe "register_user/1" do
    test "with valid data creates a user" do
      answer = Accounts.register_user(@valid_attrs)

      dbg(answer)

      :ok
    end

    # test "with invalid data returns error changeset" do
    #   assert {:error, %Ecto.Changeset{}} = Accounts.register_user(@invalid_attrs)
    # end
  end
end
