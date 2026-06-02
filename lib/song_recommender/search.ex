defmodule SongRecommender.Search do
  @moduledoc """
  Utilities to deal with search
  """

  alias SongRecommender.Artists
  alias SongRecommender.Artists.Artist
  alias SongRecommender.Songs
  alias SongRecommender.Songs.Song

  @type artist :: Artist.t()
  @type query :: String.t()
  @type song :: Song.t()
  @type username :: String.t()

  @doc """
  Searches for an item (Artist or Song) using the normalizedName property.
  Returns artists first (with artists with the most monthly listeners coming first)
  then songs.
  """

  @spec search_query(query(), username()) :: [artist() | song()]
  def search_query(query, username) do
    %Boltx.Response{results: search_items} =
      Boltx.query!(
        Bolt,
        """
        MATCH (n:Artist|Song), (u:User {name: $username})
        WHERE n.normalizedName CONTAINS $query
        OPTIONAL MATCH (n)<-[:SANG]-(a:Artist)
        CALL (*) {
          WHEN a IS NULL THEN {
            WITH EXISTS { (u)-[:FOLLOWS]->(n) } AS following
            RETURN n {
                     .*,
                     following: following,
                     id: randomUUID(),
                     monthly_listeners: n.monthlyListeners,
                     artistName: NULL,
                     popularity: NULL
                     }
                     AS searchItem
          }
          ELSE {
            MATCH (n)-[:BELONGS_TO]->(g:Genre)
            RETURN n {
                     .*,
                     duration_ms: n.durationMs,
                     artist: a {.*, id: randomUUID(), monthly_listeners: a.monthlyListeners},
                     genre: g {.*},
                     monthlyListeners: NULL
                     }
                     AS searchItem
          }
        }
        RETURN searchItem
        ORDER BY labels(n), n.popularity DESC, n.monthlyListeners DESC
        LIMIT 15
        """,
        %{query: String.downcase(query), username: username}
      )

    if Enum.empty?(search_items) do
      []
    else
      Enum.map(search_items, &process_search_item(&1))
    end
  end

  defp process_search_item(%{"searchItem" => %{"artistName" => nil} = attrs}),
    do: Artists.populate_artist(%Artist{}, attrs)

  defp process_search_item(%{"searchItem" => attrs}), do: Songs.populate_song(%Song{}, attrs)
end
