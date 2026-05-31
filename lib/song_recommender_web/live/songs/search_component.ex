defmodule SongRecommenderWeb.Songs.SearchComponent do
  @moduledoc """
  Holds the search bar and the search results
  """

  use SongRecommenderWeb, :live_component

  alias SongRecommenderWeb.CustomComponents

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div class="w-full h-[10%] flex items-center z-1000">
      <div
        id="search-bar-container"
        class="relative bg-base-300 w-[70%] max-w-[25rem] mx-auto py-3 rounded-full cursor-text"
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
          class="bg-base-300 min-h-[10rem] max-h-[20rem] py-3 rounded-2xl absolute top-[4rem] left-[-4rem] right-[-4rem] overflow-y-scroll hidden"
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
            phx-hook="SearchItems"
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
    """
  end
end
