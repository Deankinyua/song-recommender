defmodule SongRecommenderWeb.PageController do
  use SongRecommenderWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
