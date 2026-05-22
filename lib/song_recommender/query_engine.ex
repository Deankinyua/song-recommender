defmodule SongRecommender.QueryEngine do
  @moduledoc """
  Does cypher queries as instructed by the recommendation engine
  """

  alias SongRecommender.Artists
  alias SongRecommender.Genres

  def get_initial_songs(
        :genre_based,
        %{genres: genres_profile, artists: artists_profile} = _profile
      ) do
    %{nodes: genres, limit: song_limit} = genres_profile

    songs_from_genres = Genres.get_songs_from_genre(genres, song_limit)
    songs_from_artists = get_songs_from_artists(artists_profile)

    songs_from_genres ++ songs_from_artists
  end

  def get_initial_songs(:hybrid, _profile), do: :ok

  defp get_songs_from_artists(artists_profile) when is_nil(artists_profile), do: []

  defp get_songs_from_artists(%{nodes: artists, limit: song_limit} = _artists_profile),
    do: Artists.get_songs_from_artists(artists, song_limit)
end
