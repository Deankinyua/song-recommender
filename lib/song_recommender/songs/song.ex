defmodule SongRecommender.Songs.Song do
  @moduledoc """
  A song carries data about its artist and genre
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias SongRecommender.Artists.Artist
  alias SongRecommender.Genres.Genre
  alias SongRecommender.Songs.MusicalProperties

  @type attrs :: map()
  @type changeset :: Ecto.Changeset.t()
  @type t :: %__MODULE__{}

  @primary_key false
  embedded_schema do
    field :duration_ms, :integer
    field :id, :string
    field :name, :string
    field :popularity, :integer
    field :released, :integer

    embeds_one :artist, Artist, defaults_to_struct: true, on_replace: :update
    embeds_one :genre, Genre
    embeds_one :properties, MusicalProperties
  end

  @spec changeset(t(), attrs()) :: changeset()
  def changeset(song, attrs) do
    song
    |> cast(attrs, [:duration_ms, :id, :name, :popularity, :released])
    |> validate_required([:duration_ms, :id, :name])
    |> cast_embed(:artist)
    |> cast_embed(:genre)
    |> cast_embed(:properties)
  end
end
