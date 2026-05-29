defmodule SongRecommender.SongsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SongRecommender.Songs` context.
  """

  alias SongRecommender.Songs
  alias SongRecommender.Songs.Song

  @doc """
  Creates a song.
  """
  @spec song_fixture(map()) :: Song.t()
  def song_fixture(attrs \\ %{}) do
    unique_id = System.unique_integer([:positive])

    song_attrs =
      Enum.into(attrs, %{
        duration_ms: 13_223,
        id: Ecto.UUID.generate(),
        name: "some_name#{unique_id}"
      })

    Songs.populate_song(%Song{}, song_attrs)
  end
end
