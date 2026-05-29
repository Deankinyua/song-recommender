defmodule SongRecommender.ArtistsTest do
  use SongRecommender.DataCase, async: false

  @artists ["Jay Z", "Justin", "Drake", "Alkaline", "Cardi B"]
  @target_artist "Drake"

  import SongRecommender.AccountsFixtures
  import SongRecommender.GraphHelpers
  import SongRecommender.SongsFixtures

  alias SongRecommender.Artists

  defp create_sample_artists(_attrs) do
    user = user_fixture()
    _artists = create_artists(@artists)
    %{user: user}
  end

  describe "get_followed_artists/1" do
    setup [:create_sample_artists]

    test "returns the artists a user follows", %{user: user} do
      _result = Artists.follow_artist(user.name, @target_artist)
      followed_artists = Artists.get_followed_artists(user.name)

      assert Enum.sort(followed_artists) == [@target_artist]
    end

    test "returns an empty list if the user does not follow any artists", %{user: user} do
      followed_artists = Artists.get_followed_artists(user.name)
      assert followed_artists == []
    end
  end

  describe "check_following_status/2" do
    setup [:create_sample_artists]

    test "returns true if a user follows a particular artist", %{user: user} do
      _result = Artists.follow_artist(user.name, @target_artist)
      assert Artists.check_following_status(user.name, @target_artist) == true
    end

    test "returns false if a user does not follow a particular artist", %{user: user} do
      assert Artists.check_following_status(user.name, @target_artist) == false
    end
  end

  describe "set_artist_following_status/2" do
    setup [:create_sample_artists]

    test "sets the following status to false on the song if user is not following the artist", %{
      user: user
    } do
      artist_id = Ecto.UUID.generate()
      artist_attrs = %{artist: %{id: artist_id, name: @target_artist}}
      song = song_fixture(artist_attrs)
      assert song.artist.following == nil
      updated_song = Artists.set_artist_following_status(song, user.name)
      assert updated_song.artist.following == false
    end

    test "sets the following status to true on the song if user is following the artist", %{
      user: user
    } do
      _result = Artists.follow_artist(user.name, @target_artist)
      artist_id = Ecto.UUID.generate()
      artist_attrs = %{artist: %{id: artist_id, name: @target_artist}}
      song = song_fixture(artist_attrs)
      updated_song = Artists.set_artist_following_status(song, user.name)
      assert updated_song.artist.following == true
    end
  end

  describe "unfollow_artist/2" do
    setup [:create_sample_artists]

    test "unfollows a particular artist", %{user: user} do
      _result = Artists.follow_artist(user.name, @target_artist)
      assert Artists.check_following_status(user.name, @target_artist) == true
      _result = Artists.unfollow_artist(user.name, @target_artist)
      assert Artists.check_following_status(user.name, @target_artist) == false
    end
  end
end
