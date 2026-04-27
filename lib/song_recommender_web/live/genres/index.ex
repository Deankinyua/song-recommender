defmodule SongRecommenderWeb.GenresLive.Index do
  use SongRecommenderWeb, :live_view

  alias SongRecommenderWeb.CustomComponents

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="min-h-[90vh] flex">
        <section class="w-[30%]">Currently Playing Song</section>
        <section class="pt-20 pl-14 flex-1 flex flex-col border border-blue-400 gap-2">
          <div class="flex montserrat-semibold">
            <p class="w-[18%]">Name</p>
            <p>Followers</p>
          </div>

          <div class="divider max-w-[90%] my-0"></div>

          <CustomComponents.genre />
        </section>
      </div>
    </Layouts.app>
    """
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end
end
