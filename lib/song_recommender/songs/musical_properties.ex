defmodule SongRecommender.Songs.MusicalProperties do
  @moduledoc """
  Each song has these properties which describe its musical composition.
  """

  use Ecto.Schema

  import Ecto.Changeset

  @type attrs :: map()
  @type changeset :: Ecto.Changeset.t()
  @type t :: %__MODULE__{}

  @primary_key false
  embedded_schema do
    field :id, :string
    field :acousticness, :float
    field :danceability, :float
    field :energy, :float
    field :instrumentalness, :float
    field :key, :integer
    field :liveness, :float
    field :loudness, :float
    field :valence, :float
  end

  @spec changeset(t(), attrs()) :: changeset()
  def changeset(property, attrs) do
    property
    |> cast(attrs, [
      :id,
      :acousticness,
      :danceability,
      :energy,
      :instrumentalness,
      :key,
      :liveness,
      :loudness,
      :valence
    ])
    |> validate_required([
      :acousticness,
      :danceability,
      :energy,
      :instrumentalness,
      :key,
      :liveness,
      :loudness,
      :valence
    ])
  end
end
