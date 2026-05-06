defmodule SongRecommender.Artists do
  @moduledoc """
  Utilities to manage artists
  """

  @type bolt_response :: Boltx.Response.t()

  @doc """
  If this was in production, you would filter with the LISTENED_TO property
  `lastPlayedDate` to find only the songs that were listened to over the
  past month.You would add a WHERE clause:

  `WHERE listened.lastPlayedDate >= datetime() - duration({days: 30})`
  """

  @spec update_monthly_listeners :: bolt_response()
  def update_monthly_listeners do
    Boltx.query!(
      Bolt,
      """
      MATCH (artist:Artist)-[SANG]->(:Song)<-[listened:LISTENED_TO]-(:User)
      WITH artist, count(listened) AS listenerCount
      SET artist.monthlyListeners = listenerCount
      """
    )
  end
end
