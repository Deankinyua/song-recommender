defmodule SongRecommender.GraphHelpers do
  @moduledoc """
  Helpers to add and clear graph data.
  """

  @type bolt_response :: Boltx.Response.t()

  @doc """
  Clears the graph so that the next test can start on a clean slate
  """

  @spec clear_graph :: bolt_response()
  def clear_graph do
    Boltx.query!(
      Bolt,
      """
      MATCH (n)
      DETACH DELETE n
      """
    )
  end
end
