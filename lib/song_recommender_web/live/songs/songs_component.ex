defmodule SongRecommenderWeb.Songs.SongsComponent do
  @moduledoc """
  Holds the songs to be played
  """

  use SongRecommenderWeb, :live_component

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div class="w-[92%] h-[80%] mx-auto flex flex-col justify-between border border-red-400">
      <section class="">songs</section>
    </div>
    """
  end
end
