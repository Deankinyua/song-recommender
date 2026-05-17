defmodule SongRecommenderWeb.Songs.SongsComponent do
  @moduledoc """
  Holds the songs and the search bar
  """

  use SongRecommenderWeb, :live_component

  alias SongRecommenderWeb.CustomComponents

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <section class="flex-1 flex flex-col items-center gap-2">
      <div class="w-full h-[10%] flex items-center border border-blue-400">
        <div
          id="search-bar-container"
          class="relative bg-base-50 w-[70%] max-w-[25rem] mx-auto py-3 rounded-full text-base-100 border border-gray cursor-text"
          phx-click={
            JS.show(to: "#search-results", transition: "fade-in-scale")
            |> JS.focus(to: "#search-query")
          }
          phx-click-away={JS.hide(to: "#search-results", transition: "fade-out-scale")}
        >
          <form
            phx-submit="search_submit"
            phx-change="search_submit"
            class="flex gap-2 items-center"
            autocomplete="off"
          >
            <section class="w-[2rem] h-[2rem] ml-3">
              <CustomComponents.search />
            </section>
            <section class="w-[80%]">
              <input
                id="search-query"
                type="text"
                name="search_query"
                value={@search_query}
                placeholder="Discover music and artists"
                phx-debounce="500"
                class="w-full border-none outline-none happy-monkey-bold placeholder:text-base-100"
              />
            </section>
          </form>
          <section
            id="search-results"
            class="bg-base-50 min-h-[10rem] max-h-[20rem] py-3 rounded-2xl absolute top-[4rem] left-[-4rem] right-[-4rem] overflow-y-scroll hidden"
          >
            <div :if={@show_recent_searches?}>
              <div class="rounded-md py-2 px-2 mx-3 happy-monkey-regular">
                Recent searches
              </div>
            </div>
            <div :if={!@show_recent_searches? && @empty_search?}>
              <div class="rounded-md py-2 px-2 mx-3 happy-monkey-regular">
                Sorry dawg I don't have those songs
              </div>
            </div>
            <div
              id="search-items"
              phx-update="stream"
            >
              <div
                :for={{dom_id, {search_item, image_number}} <- @search_items}
                id={dom_id}
              >
                <CustomComponents.search_item item={search_item} image={image_number} />
              </div>
            </div>
          </section>
        </div>
      </div>

      <div class="w-[92%] h-[90%] mx-auto flex flex-col justify-between">
        <section class="border border-red-400">songs</section>
        <section
          id="song-player"
          phx-hook="SongPlayer"
          class="h-[15%] bg-base-50 flex flex-col gap-2 justify-center items-center song-player text-base-100"
        >
          <div class="w-[60%] flex justify-center items-center gap-4">
            <div class="w-[2.5rem] flex justify-center">
              <CustomComponents.back_icon />
            </div>
            <div class="w-[2.5rem] flex justify-center">
              <CustomComponents.play_pause_icon />
            </div>
            <div class="w-[2.5rem] flex justify-center">
              <CustomComponents.next_icon />
            </div>
          </div>

          <CustomComponents.song_progress_bar />
        </section>
      </div>
    </section>
    """
  end
end
