defmodule SongRecommender.Search do
  @moduledoc """
  Utilities to deal with search
  """

  alias SongRecommender.Artists.Artist
  alias SongRecommender.Songs.Song

  @type artist :: Artist.t()
  @type query :: String.t()
  @type song :: Song.t()

  @doc """
  Searches for an item (Artist or Song) using the normalizedName property.
  Returns artists first (most listened_to artist first) then songs.
  """
  @spec search_query(query()) :: [artist() | song()]
  def search_query(query) do
    %Boltx.Response{results: search_items} =
      Boltx.query!(
        Bolt,
        """
        MATCH (n:Artist|Song)
        WHERE n.normalizedName CONTAINS $query
        OPTIONAL MATCH (n)<-[:SANG]-(a:Artist)
        WITH n, a
        CALL (*) {
          WHEN a IS NULL THEN {
            RETURN n {.name, .monthlyListeners, id: NULL, artistName: NULL} AS searchItem
          }
          WHEN a IS NOT NULL THEN {
            RETURN n {.name, .id, monthlyListeners: NULL, artistName: a.name} AS searchItem
          }
        }
        RETURN searchItem
        ORDER BY labels(n), n.monthlyListeners DESC
        LIMIT 15
        """,
        %{query: String.downcase(query)}
      )

    if Enum.empty?(search_items) do
      []
    else
      Enum.map(search_items, &process_search_item(&1))
    end
  end

  defp process_search_item(%{
         "searchItem" => %{
           "artistName" => nil,
           "monthlyListeners" => monthly_listeners,
           "name" => artist_name
         }
       }),
       do: %Artist{id: Ecto.UUID.generate(), listeners: monthly_listeners, name: artist_name}

  defp process_search_item(%{
         "searchItem" => %{
           "artistName" => artist_name,
           "id" => song_id,
           "name" => song_name
         }
       }),
       do: %Song{id: song_id, name: song_name, sang_by: artist_name}
end
