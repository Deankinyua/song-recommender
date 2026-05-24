defmodule SongRecommenderWeb.Songs.PlayerComponent do
  @moduledoc """
  Holds the song player and progress bar.
  """

  use SongRecommenderWeb, :live_component

  alias SongRecommenderWeb.CustomComponents

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <section
      id="song-player"
      phx-hook="SongPlayer"
      class="w-[92%] h-[16%] bg-base-50 flex flex-col gap-2 justify-center items-center song-player text-base-100"
    >
      <div class="w-[60%] flex justify-center items-center gap-4">
        <div id="back-icon" class="control-icon">
          <CustomComponents.back_icon />
          <div class="top-[-1.8rem] left-[-1.4rem] tooltip">
            Back
          </div>
        </div>
        <div id="play-icon" class="control-icon">
          <CustomComponents.player_play_icon />
          <div id="pause-play-tooltip" class="top-[-1.8rem] left-0 tooltip">
            Play
          </div>
        </div>
        <div id="next-icon" class="control-icon">
          <CustomComponents.next_icon />
          <div class="top-[-1.8rem] left-[-0.4rem] tooltip">
            Next
          </div>
        </div>
        <div id="skip-icon" class="control-icon">
          <CustomComponents.skip_icon />

          <div class="top-[-1.3rem] left-[-0.4rem] tooltip">
            Skip
          </div>
        </div>
      </div>

      <CustomComponents.song_progress_bar />
    </section>
    """
  end
end
