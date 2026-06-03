defmodule SongRecommender.QueryEngine do
  @moduledoc """
  Does cypher queries as instructed by the recommendation engine
  """

  alias SongRecommender.Songs

  def get_songs(:genre_based, username, taste_profile),
    do: Songs.get_songs_with_genre_based_strategy(username, taste_profile)

  def get_songs(:hybrid, _username, _taste_profile), do: :ok
end
