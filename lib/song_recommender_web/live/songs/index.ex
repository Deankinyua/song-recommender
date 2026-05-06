defmodule SongRecommenderWeb.SongsLive.Index do
  use SongRecommenderWeb, :live_view

  alias SongRecommenderWeb.CustomComponents

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="min-h-[90vh] flex">
        <section class="w-[25%] border border-red-400"></section>
        <section class="flex-1 flex flex-col items-center gap-6">
          <div class="mt-4 w-[50%] max-w-[27rem] mx-auto py-2 rounded-2xl border border-gray">
            <form
              phx-submit="search_submit"
              phx-change="search_submit"
              class="flex gap-2 items-center"
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
                  placeholder="Search for music and artists..."
                  phx-debounce="700"
                  class="w-full border-none outline-none"
                />
              </section>
            </form>
          </div>

          <div class="w-[90%] mx-auto">Previously played songs</div>
        </section>

        <section class="w-[25%] border border-red-400"></section>
      </div>
    </Layouts.app>
    """
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:search_query, "")}
  end

  @impl Phoenix.LiveView
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end
end
