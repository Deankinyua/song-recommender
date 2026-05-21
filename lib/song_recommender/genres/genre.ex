defmodule SongRecommender.Genres.Genre do
  @moduledoc """
  A genre
  """

  use Ecto.Schema

  @type t :: %__MODULE__{}

  embedded_schema do
    field :name, :string
  end
end
