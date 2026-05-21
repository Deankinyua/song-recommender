defmodule SongRecommender.Genres.Genre do
  @moduledoc """
  A genre must be one of the 35 genres present in our DB.
  """

  use Ecto.Schema

  @type t :: %__MODULE__{}

  embedded_schema do
    field :name, :string
  end
end
