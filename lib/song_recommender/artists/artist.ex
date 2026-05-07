defmodule SongRecommender.Artists.Artist do
  @moduledoc """
  An artist
  """

  use Ecto.Schema

  @type t :: %__MODULE__{}

  embedded_schema do
    field :name, :string
    field :listeners, :integer
  end
end
