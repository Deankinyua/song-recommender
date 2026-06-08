defmodule SongRecommender.Genres.Genre do
  @moduledoc """
  A genre must be one of the 35 genres present in our DB.
  """

  use Ecto.Schema

  import Ecto.Changeset

  @valid_genres Application.compile_env!(:song_recommender, :genres)

  @type attrs :: map()
  @type changeset :: Ecto.Changeset.t()
  @type t :: %__MODULE__{}

  @primary_key false
  embedded_schema do
    field :name, :string
  end

  @spec changeset(t(), attrs()) :: changeset()
  def changeset(genre, attrs) do
    genre
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_inclusion(:name, @valid_genres)
  end
end
