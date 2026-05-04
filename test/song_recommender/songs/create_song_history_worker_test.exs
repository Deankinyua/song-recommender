defmodule SongRecommender.Songs.CreateSongHistoryWorkerTest do
  use SongRecommender.DataCase, async: false

  import SongRecommender.AccountsFixtures
  import SongRecommender.GraphHelpers

  alias SongRecommender.Songs
  alias SongRecommender.Songs.CreateSongHistoryWorker

  @target_genre "hip-hop"

  defp create_sample_songs(_attrs) do
    user = user_fixture()
    song_ids = create_songs_with_genre(@target_genre)
    %{song_ids: song_ids, user: user}
  end

  describe "perform/1" do
    setup [:create_sample_songs]

    test "listens to songs from the target genres", %{
      song_ids: song_ids,
      user: %{name: username}
    } do
      song_distribution = [%{genre: @target_genre, limit: 4}]

      assert :ok =
               perform_job(CreateSongHistoryWorker, %{
                 name: username,
                 song_distribution: song_distribution
               })

      [song_1_id, song_2_id, song_3_id] = song_ids

      assert check_for_listens(username, song_1_id)
      assert check_for_listens(username, song_2_id)
      assert check_for_listens(username, song_3_id)

      song = Songs.get_song!(song_1_id)
      song_listen_time = Songs.get_song_listening_time(song_1_id, username)

      assert song_listen_time == song.duration_ms * 2
    end
  end
end
