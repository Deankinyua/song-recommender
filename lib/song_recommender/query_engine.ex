defmodule SongRecommender.QueryEngine do
  @moduledoc """
  Does cypher queries as instructed by the recommendation engine
  """

  alias SongRecommender.ContentBasedFilteringEngine
  alias SongRecommender.Songs
  alias SongRecommender.Songs.Song

  @type song :: Song.t()
  @type username :: String.t()

  @spec get_similar_songs(map()) :: [song()]
  def get_similar_songs(%{id: song_id} = song_information) do
    get_songs = Task.async(fn -> Songs.get_songs_properties(song_information) end)
    target_song_attributes = Songs.get_song_musical_properties(song_id)
    songs_attributes = Task.await(get_songs)

    songs_attributes
    |> ContentBasedFilteringEngine.filter_similar_songs(target_song_attributes)
    |> Songs.get_multiple_songs()
  end

  @spec get_songs(atom(), username(), map()) :: [song()]
  def get_songs(:genre_based, username, taste_profile),
    do: Songs.get_songs_with_genre_based_strategy(username, taste_profile)

  def get_songs(:hybrid, _username, _taste_profile), do: :ok
end
