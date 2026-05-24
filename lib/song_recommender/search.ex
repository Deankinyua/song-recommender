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
            RETURN n {.name, .monthlyListeners, artistName: NULL, popularity: NULL} AS searchItem
          }
          WHEN a IS NOT NULL THEN {
            RETURN n {.name, .id, .popularity, .durationMs, artistMonthlyListeners: a.monthlyListeners, artistName: a.name, monthlyListeners: NULL} AS searchItem
          }
        }
        RETURN searchItem
        ORDER BY labels(n), n.popularity DESC, n.monthlyListeners DESC
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
           "name" => artist_name
         }
       }),
       do: %Artist{id: Ecto.UUID.generate(), name: artist_name}

  defp process_search_item(%{
         "searchItem" => %{
           "artistMonthlyListeners" => artist_monthly_listeners,
           "artistName" => artist_name,
           "durationMs" => song_duration,
           "id" => song_id,
           "name" => song_name
         }
       }) do
    artist = %Artist{name: artist_name, listeners: artist_monthly_listeners}

    %Song{
      artist: artist,
      duration_ms: song_duration,
      id: song_id,
      name: song_name
    }
  end
end
