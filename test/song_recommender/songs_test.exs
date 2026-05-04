defmodule SongRecommender.SongsTest do
  use SongRecommender.DataCase, async: false

  import SongRecommender.AccountsFixtures
  import SongRecommender.GraphHelpers

  alias SongRecommender.Songs

  @target_genre "hip-hop"

  defp create_sample_songs(_attrs) do
    song_ids = create_songs_with_genre(@target_genre)
    %{song_ids: song_ids}
  end

  describe "get_song!/1" do
    setup [:create_sample_songs]

    test "returns a song if it exists", %{song_ids: song_ids} do
      [most_popular_song_id | _other_song_ids] = song_ids
      retrieved_song = Songs.get_song!(most_popular_song_id)

      assert retrieved_song.id == most_popular_song_id
    end

    test "returns nil for a song that doesn't exist" do
      refute Songs.get_song!("6MYPzdIWgx4pMLRGlq2fVq")
    end
  end

  describe "listen_from_genre/2" do
    setup do
      user = user_fixture()
      song_ids = create_songs_with_genre(@target_genre)
      %{song_ids: song_ids, user: user}
    end

    test "listens to the most popular song in the genre", %{
      song_ids: song_ids,
      user: %{name: username}
    } do
      [most_popular_song_id | _other_song_ids] = song_ids
      refute check_for_listens(username, most_popular_song_id)

      Songs.listen_from_genre(username, @target_genre)
      assert check_for_listens(username, most_popular_song_id)
    end

    test "listens to the most popular song more than once if all songs have already been listened to",
         %{song_ids: song_ids, user: %{name: username}} do
      [song_1_id, _song_2_id, song_3_id] = song_ids

      for _num <- 1..3 do
        Songs.listen_from_genre(username, @target_genre)
      end

      assert check_for_listens(username, song_3_id)

      Songs.listen_from_genre(username, @target_genre)

      song = Songs.get_song!(song_1_id)
      song_listen_time = Songs.get_song_listening_time(song_1_id, username)

      assert song_listen_time == song.duration_ms * 2
    end
  end
end
