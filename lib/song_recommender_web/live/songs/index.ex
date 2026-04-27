defmodule SongRecommenderWeb.SongsLive.Index do
  use SongRecommenderWeb, :live_view

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="min-h-[90vh] flex">
        <section class="w-[30%]">Currently Playing Song</section>
        <section class="flex-1">Songs - Previous Songs and Recommended Songs</section>
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
