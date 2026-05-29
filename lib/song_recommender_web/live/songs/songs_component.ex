defmodule SongRecommenderWeb.Songs.SongsComponent do
  @moduledoc """
  Holds the songs to be played
  """

  use SongRecommenderWeb, :live_component

  alias SongRecommenderWeb.CustomComponents

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div
      phx-hook="Songs"
      id="songs"
      phx-update="stream"
      class="w-[92%] h-[75%] mx-auto mb-3 py-4 px-2 bg-base-70 rounded-xl flex flex-col justify-between happy-monkey-regular overflow-y-scroll"
    >
      <div
        :for={{dom_id, {song, image_number, song_number}} <- @songs}
        id={dom_id}
      >
        <CustomComponents.song song={song} image={image_number} song_number={song_number} />
      </div>
    </div>
    """
  end
end
