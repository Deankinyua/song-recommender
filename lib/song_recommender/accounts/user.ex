defmodule SongRecommender.Accounts.User do
  @moduledoc """
  The Application User
  """

  use Ecto.Schema

  import Ecto.Changeset

  @type attrs :: map()
  @type changeset :: Ecto.Changeset.t()
  @type t :: %__MODULE__{}

  @primary_key false
  embedded_schema do
    field(:genres, {:array, :string}, default: [])
    field(:name, :string)
    field(:yob, :integer)
  end

  @spec changeset(t(), attrs()) ::
          changeset()
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:genres, :name, :yob])
    |> validate_required([:name, :yob])
    |> validate_length(:name, min: 4, message: "Your name must be at least 4 characters long")
    |> validate_number(:yob,
      less_than: 2022,
      greater_than: 1950,
      message: "Your year of birth must be between 1950 and 2022"
    )
  end
end
