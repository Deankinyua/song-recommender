defmodule SongRecommender.Artists.Artist do
  @moduledoc """
  An artist
  """

  use Ecto.Schema

  import Ecto.Changeset

  @type attrs :: map()
  @type changeset :: Ecto.Changeset.t()
  @type t :: %__MODULE__{}

  @primary_key false
  embedded_schema do
    field :following, :boolean
    field :id, :string
    field :monthly_listeners, :integer
    field :name, :string
  end

  @spec changeset(t(), attrs()) :: changeset()
  def changeset(artist, attrs) do
    artist
    |> cast(attrs, [:following, :id, :monthly_listeners, :name])
    |> validate_required([:name, :id])
  end
end
