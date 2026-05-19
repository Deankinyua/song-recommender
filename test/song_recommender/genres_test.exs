defmodule SongRecommender.GenresTest do
  use SongRecommender.DataCase, async: false

  import SongRecommender.AccountsFixtures
  import SongRecommender.GraphHelpers

  alias SongRecommender.Genres

  @example_genres ["hip-hop", "pop", "dancehall", "house", "gospel"]

  defp create_sample_genres(_attrs) do
    genres = create_genres(@example_genres)
    user = user_fixture()
    updated_user = Genres.prefer_genres(user.name, genres)
    %{genres: genres, user: updated_user}
  end

  describe "get_user_genres/1" do
    setup [:create_sample_genres]

    test "returns genres that the user has preferred", %{genres: genres, user: user} do
      fetched_genres = Genres.get_user_genres(user.name)
      assert Enum.sort(fetched_genres) == Enum.sort(genres)
    end

    test "returns an empty list if user hasn't preferred any genres" do
      user = user_fixture()
      fetched_genres = Genres.get_user_genres(user.name)
      assert fetched_genres == []
    end
  end

  describe "prefer_genres/2" do
    setup [:create_sample_genres]

    test "deletes previously preferred genres", %{user: user} do
      fetched_genres = Genres.get_user_genres(user.name)
      assert length(fetched_genres) == 5

      updated_user = Genres.prefer_genres(user.name, ["pop"])
      newly_fetched_genres = Genres.get_user_genres(user.name)
      assert length(newly_fetched_genres) == 1
      assert updated_user.genres == newly_fetched_genres
    end

    test "creates a preferred relationship between users and genres" do
      user = user_fixture()
      fetched_genres = Genres.get_user_genres(user.name)
      assert fetched_genres == []

      updated_user = Genres.prefer_genres(user.name, @example_genres)
      assert Enum.sort(updated_user.genres) == Enum.sort(@example_genres)
    end
  end
end
