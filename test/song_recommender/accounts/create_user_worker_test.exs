defmodule SongRecommender.Accounts.CreateUserWorkerTest do
  use SongRecommender.DataCase, async: true

  alias SongRecommender.Accounts.CreateUserWorker
  alias SongRecommender.Songs.CreateSongHistoryWorker

  @valid_username "Marion"
  @valid_yob 1997
  @invalid_yob 1800

  describe "perform/1" do
    test "enqueues a create_listening_history job if creating a user is successful" do
      listening_history = [
        %{"genre" => "hip-hop", "limit" => 132},
        %{"genre" => "house", "limit" => 67},
        %{"genre" => "dancehall", "limit" => 49},
        %{"genre" => "gospel", "limit" => 34},
        %{"genre" => "trip-hop", "limit" => 28}
      ]

      assert :ok =
               perform_job(CreateUserWorker, %{
                 name: @valid_username,
                 yob: @valid_yob,
                 listening_history: listening_history
               })

      assert_enqueued(
        worker: CreateSongHistoryWorker,
        args: %{
          "name" => @valid_username,
          "song_distribution" => listening_history
        }
      )
    end

    test "does not enqueue a create_listening_history job if creating a user is unsuccessful" do
      listening_history = [
        %{"genre" => "hip-hop", "limit" => 132},
        %{"genre" => "house", "limit" => 67},
        %{"genre" => "dancehall", "limit" => 49},
        %{"genre" => "gospel", "limit" => 34},
        %{"genre" => "trip-hop", "limit" => 28}
      ]

      assert {:error, reason} =
               perform_job(CreateUserWorker, %{
                 name: @valid_username,
                 yob: @invalid_yob,
                 listening_history: listening_history
               })

      assert reason =~ "Failed to create the user"

      refute_enqueued(worker: CreateSongHistoryWorker)
    end
  end
end
