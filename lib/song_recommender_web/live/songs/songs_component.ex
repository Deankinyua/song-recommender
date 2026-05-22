defmodule SongRecommenderWeb.Songs.SongsComponent do
  @moduledoc """
  Holds the songs to be played
  """

  use SongRecommenderWeb, :live_component

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div class="w-[92%] h-[80%] mx-auto mb-3 p-3 bg-base-70 rounded-xl flex flex-col justify-between">
      <section class="">songs</section>
    </div>
    """
  end
end
