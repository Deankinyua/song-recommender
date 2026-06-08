defmodule SongRecommender.ContentBasedEngine do
  @moduledoc """
  Returns songs similar to a target song based on their musical properties.
  """

  alias SongRecommender.SongSimilarity

  @type song_data :: map()
  @type song_id :: String.t()

  @doc """
  Takes a bunch of songs and returns the 15 most similar ones based on their
  cosine similarity
  """

  @spec filter_similar_songs([song_data()], song_data()) :: [song_id()]
  def filter_similar_songs(songs_data, target_song_data) do
    songs_tensor =
      songs_data
      |> Enum.map(&return_song_attributes(&1))
      |> Nx.tensor()

    target_song_tensor =
      target_song_data
      |> return_target_song_attributes()
      |> Nx.tensor()

    target_song_p_norm =
      target_song_data
      |> return_song_attributes()
      |> Nx.tensor()
      |> Nx.LinAlg.norm()

    cosine_similarity_result =
      songs_tensor
      |> SongSimilarity.cosine_similarity(target_song_tensor, target_song_p_norm)
      |> Nx.to_flat_list()

    songs_data
    |> Stream.map(& &1.id)
    |> Stream.zip(cosine_similarity_result)
    |> Enum.sort_by(fn {_id, score} -> score end, :desc)
    |> Enum.take(18)
    |> Enum.map(fn {id, _score} -> id end)
  end

  defp return_song_attributes(
         %{
           acousticness: acousticness,
           danceability: danceability,
           energy: energy,
           instrumentalness: instrumentalness,
           key: key,
           liveness: liveness,
           loudness: loudness,
           valence: valence
         } = _properties
       ) do
    [acousticness, danceability, energy, instrumentalness, key, liveness, loudness, valence]
  end

  defp return_target_song_attributes(
         %{
           acousticness: acousticness,
           danceability: danceability,
           energy: energy,
           instrumentalness: instrumentalness,
           key: key,
           liveness: liveness,
           loudness: loudness,
           valence: valence
         } = _properties
       ) do
    [
      [acousticness],
      [danceability],
      [energy],
      [instrumentalness],
      [key],
      [liveness],
      [loudness],
      [valence]
    ]
  end
end
