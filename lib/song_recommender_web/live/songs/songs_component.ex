defmodule SongRecommenderWeb.Songs.SongsComponent do
  @moduledoc """
  Holds the songs and the search bar
  """

  use SongRecommenderWeb, :live_component

  alias SongRecommenderWeb.CustomComponents

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <section class="flex-1 flex flex-col items-center gap-6">
      <div
        id="search-bar-container"
        class="relative bg-base-50 mt-4 w-[70%] max-w-[25rem] mx-auto py-3 rounded-full border border-gray"
        phx-click={JS.show(to: "#search-results", transition: "fade-in-scale")}
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
              class="w-full border-none outline-none text-base-content happy-monkey-bold placeholder:text-base-content"
            />
          </section>
        </form>

        <section
          id="search-results"
          class="bg-base-50 min-h-[10rem] max-h-[20rem] py-3 rounded-2xl absolute top-[4rem] left-[-4rem] right-[-4rem] overflow-y-scroll hidden"
        >
          <div
            :for={{dom_id, {search_item, image_number}} <- @search_items}
            id={dom_id}
            class=""
          >
            <CustomComponents.search_item item={search_item} image={image_number} />
          </div>
        </section>
      </div>

      <div class="w-[90%] mx-auto"></div>
    </section>
    """
  end
end
