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
    songs_from_genres = get_songs(:genre, genres_profile)
    songs_from_artists = get_songs(:artist, artists_profile)

    songs_from_genres ++ songs_from_artists
  end

  def get_initial_songs(:hybrid, _profile), do: :ok

  defp get_songs(_node_type, profile) when is_nil(profile), do: []

  defp get_songs(:artist, %{nodes: artists, limit: song_limit} = _artists_profile),
    do: Artists.get_songs_from_artists(artists, song_limit)

  defp get_songs(:genre, %{nodes: genres, limit: song_limit} = _genres_profile),
    do: Genres.get_songs_from_genre(genres, song_limit)
end
