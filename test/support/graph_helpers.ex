defmodule SongRecommender.GraphHelpers do
  @moduledoc """
  Helpers to add and clear graph data.
  """

  @type bolt_response :: Boltx.Response.t()
  @type genre :: String.t()

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

  @spec create_songs_with_genre(genre()) :: bolt_response()
  def create_songs_with_genre(genre) do
    Bolt
    |> Boltx.query!(
      """
       CREATE (song_1:Song {id: "6VtoP2sJt5oCmPOQIve2sf", durationMs: 166240, name: "Someone Like You", popularity: 70, released: 2012}),
              (song_2:Song {id: "2EKxmYmUdAVXlaHCnnW13o", durationMs: 220160, name: "Heaven", popularity: 58, released: 2012}),
              (song_3:Song {id: "7KG9zriC6iP8F1CNihtR8Y", durationMs: 216387, name: "Princess", popularity: 39, released: 2014}),

              (genre_1:Genre {name: $genre}),
              (artist_1:Artist {name: 'Kendrick'}),
              (artist_2:Artist {name: 'Drake'}),

              (song_1)-[:BELONGS_TO]->(genre_1),
              (song_2)-[:BELONGS_TO]->(genre_1),
              (song_3)-[:BELONGS_TO]->(genre_1),
              (artist_1)-[:SANG]->(song_1),
              (artist_1)-[:SANG]->(song_2),
              (artist_2)-[:SANG]->(song_3)
       RETURN [song_1.id, song_2.id, song_3.id] AS songs
      """,
      %{genre: genre}
    )
    |> Boltx.Response.first()
    |> return_song_ids()
  end

  def check_for_listens(username, song_id) do
    Bolt
    |> Boltx.query!(
      """
      RETURN exists( (:User {name: $name})-[:LISTENED_TO]->(:Song {id: $song_id}) ) AS listened_status
      """,
      %{name: username, song_id: song_id}
    )
    |> Boltx.Response.first()
    |> user_listened_to_song?()
  end

  @spec create_genres([genre()]) :: bolt_response()
  def create_genres(genres) do
    Bolt
    |> Boltx.query!(
      """
       UNWIND $genres AS genre
       CREATE (g:Genre {name: genre})
       RETURN collect(g.name) AS genres
      """,
      %{genres: genres}
    )
    |> Boltx.Response.first()
    |> return_genres()
  end

  defp return_genres(%{"genres" => genres}), do: genres
  defp return_song_ids(%{"songs" => song_ids}), do: song_ids
  defp user_listened_to_song?(%{"listened_status" => status}), do: status
end
