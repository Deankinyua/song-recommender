defmodule SongRecommender.SongSimilarity do
  @moduledoc """
  Calculates the cosine similarity betweeen one song and a bunch of songs
  """

  import Nx.Defn

  @doc """
  Calculates the cosine similarity between x and y where x is a tensor representing
  many songs and their attributes, y is a tensor representing a target song's attributes
  and p_norm_y is the p_norm of y
  """

  defn cosine_similarity(x, y, p_norm_y) do
    sum_of_dot_product = Nx.dot(x, y)

    p_norm_x = Nx.LinAlg.norm(x, axes: [1])

    product_of_the_lengths = Nx.multiply(p_norm_x, p_norm_y)

    sum_of_dot_product
    |> Nx.squeeze()
    |> Nx.divide(product_of_the_lengths)
  end
end
