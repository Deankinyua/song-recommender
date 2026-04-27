defmodule SongRecommender.Repo do
  use Ecto.Repo,
    otp_app: :song_recommender,
    adapter: Ecto.Adapters.Postgres
end
