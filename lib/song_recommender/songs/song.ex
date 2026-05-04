defmodule SongRecommender.Songs.Song do
  @moduledoc """
  A song
  """

  use Ecto.Schema

  @type t :: %__MODULE__{}

  @primary_key false
  embedded_schema do
    field(:duration_ms, :integer)
    field(:id, :string)
    field(:name, :string)
    field(:popularity, :integer)
    field(:released, :integer)
  end
end
