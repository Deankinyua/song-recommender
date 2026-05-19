defmodule SongRecommender.Accounts.User do
  @moduledoc """
  The Application User
  """

  use Ecto.Schema

  import Ecto.Changeset

  @valid_genres Application.compile_env!(:song_recommender, :genres)

  @type attrs :: map()
  @type changeset :: Ecto.Changeset.t()
  @type t :: %__MODULE__{}

  @primary_key false
  embedded_schema do
    field :genres, {:array, :string}, default: []
    field :name, :string
  end

  @spec changeset(t(), attrs()) ::
          changeset()
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:genres, :name])
    |> validate_required([:name])
    |> validate_length(:name, min: 4, message: "Your name must be at least 4 characters long")
    |> validate_subset(:genres, @valid_genres, message: "You selected an invalid entry")
  end
end
