defmodule SongRecommender.Songs.Song do
  @moduledoc """
  A song carries data about its artist and genre
  """

  use Ecto.Schema

  alias SongRecommender.Artists.Artist
  alias SongRecommender.Genres.Genre

  @type t :: %__MODULE__{}

  @primary_key false
  embedded_schema do
    field :duration_ms, :integer
    field :id, :string
    field :name, :string
    field :popularity, :integer
    field :released, :integer

    embeds_one :artist, Artist
    embeds_one :genre, Genre
  end
end
