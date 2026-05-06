defmodule SongRecommender.Search do
  @moduledoc """
  Utilities to deal with search
  """

  alias SongRecommender.Artists.Artist
  alias SongRecommender.Songs.Song

  @type artist :: Artist.t()
  @type query :: String.t()
  @type song :: Song.t()

  @spec search_query(query()) :: [artist() | song()]
  def search_query(query) do
    %Boltx.Response{results: search_items} =
      Boltx.query!(
        Bolt,
        """
        MATCH (n:Artist|Song)
        WHERE n.normalized_name CONTAINS $query

        OPTIONAL MATCH (n)<-[:SANG]-(a:Artist)

        WITH n, a,
        CASE
          WHEN n.duration_ms IS NOT NULL THEN 'song'
          ELSE 'artist'
        END AS sangBy

        RETURN n {
        .name,
        .id,
        artistName:
        CASE
          WHEN sangBy = 'song' THEN a.name
          ELSE NULL
        END
        } AS searchItem

        ORDER BY sangBy
        LIMIT 10;
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
       do: %Artist{name: artist_name}

  defp process_search_item(%{
         "searchItem" => %{
           "artistName" => artist_name,
           "id" => song_id,
           "name" => song_name
         }
       }),
       do: %Song{id: song_id, name: song_name, sang_by: artist_name}
end
