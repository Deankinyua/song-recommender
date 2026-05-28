defmodule SongRecommender.ArtistsTest do
  use SongRecommender.DataCase, async: false

  @artists ["Jay Z", "Justin", "Drake", "Alkaline", "Cardi B"]

  import SongRecommender.AccountsFixtures
  import SongRecommender.GraphHelpers

  alias SongRecommender.Artists

  defp create_sample_artists(_attrs) do
    user = user_fixture()
    _artists = create_artists(@artists)
    %{user: user}
  end

  describe "get_followed_artists/1" do
    setup [:create_sample_artists]

    test "returns the artists a user follows", %{user: user} do
      _result = Artists.follow_artist(user.name, "Drake")
      _result = Artists.follow_artist(user.name, "Alkaline")

      followed_artists = Artists.get_followed_artists(user.name)

      assert Enum.sort(followed_artists) == ["Alkaline", "Drake"]
    end

    test "returns an empty list if the user does not follow any artists", %{user: user} do
      followed_artists = Artists.get_followed_artists(user.name)
      assert followed_artists == []
    end
  end

  describe "check_following_status/2" do
    setup [:create_sample_artists]

    test "returns true if a user follows a particular artist", %{user: user} do
      _result = Artists.follow_artist(user.name, "Drake")
      assert Artists.check_following_status(user.name, "Drake") == true
    end

    test "returns false if a user does not follow a particular artist", %{user: user} do
      assert Artists.check_following_status(user.name, "Drake") == false
    end
  end
end
