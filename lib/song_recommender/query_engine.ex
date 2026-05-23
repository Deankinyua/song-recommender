defmodule SongRecommender.QueryEngine do
  @moduledoc """
  Does cypher queries as instructed by the recommendation engine
  """

  alias SongRecommender.Songs

  def get_initial_songs(:genre_based, taste_profile),
    do: Songs.get_songs_with_genre_based_strategy(taste_profile)

  def get_initial_songs(:hybrid, _taste_profile), do: :ok
end
