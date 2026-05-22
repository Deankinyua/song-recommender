defmodule SongRecommenderWeb.SongsLive.Index do
  use SongRecommenderWeb, :live_view

  alias SongRecommender.EngineQueueSupervisor
  alias SongRecommender.Genres
  alias SongRecommender.Search
  alias SongRecommenderWeb.Songs.GenresPopupComponent
  alias SongRecommenderWeb.Songs.PlayerComponent
  alias SongRecommenderWeb.Songs.SearchComponent
  alias SongRecommenderWeb.Songs.SongsComponent

  @image_list 1..15

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} class="bg-base-50" username={@current_user.name}>
      <div class="h-[92vh] flex text-base-100">
        <section class="w-[25%] relative">
          <.live_component
            id="genres-popup-component"
            module={GenresPopupComponent}
            user_genres={@genres}
            show_modal?={@capture_user_preferences?}
            user={@current_user}
          />
        </section>
        <section class="flex-1 flex flex-col items-center gap-2 border border-blue-400">
          <.live_component
            id="search-component"
            module={SearchComponent}
            empty_search?={@empty_search?}
            search_items={@streams.search_items}
            search_query={@search_query}
            show_recent_searches?={@show_recent_searches?}
          />

          <.live_component
            id="songs-component"
            module={SongsComponent}
          />

          <.live_component
            id="player-component"
            module={PlayerComponent}
          />
        </section>

        <section class="w-[25%]"></section>
      </div>
    </Layouts.app>
    """
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> maybe_fetch_genres()
     |> setup_recommendation_engine()
     |> stream_configure(:search_items, dom_id: &"search-item-#{elem(&1, 0).id}")}
  end

  @impl Phoenix.LiveView
  def handle_params(params, _url, socket) do
    search_query = params["q"] || ""

    case search_query != "" do
      true ->
        search_items = Search.search_query(search_query)
        search_items_empty? = Enum.empty?(search_items)

        search_items_with_images =
          if search_items_empty?, do: [], else: add_image_numbers(search_items)

        {:noreply,
         socket
         |> assign(:empty_search?, search_items_empty?)
         |> assign(:search_query, search_query)
         |> assign(:show_recent_searches?, false)
         |> stream(:search_items, search_items_with_images, reset: true)}

      false ->
        # later on we will refactor to fetch recent searches to replace the []
        {:noreply,
         socket
         |> assign(:empty_search?, true)
         |> assign(:show_recent_searches?, true)
         |> assign(:search_query, "")
         |> stream(:search_items, [], reset: true)}
    end
  end

  @impl Phoenix.LiveView
  def handle_event("search_submit", %{"search_query" => query}, socket) do
    trimmed_query =
      query
      |> to_string()
      |> String.trim()

    if trimmed_query != "" do
      {:noreply, push_patch(socket, to: ~p"/?q=#{trimmed_query}")}
    else
      {:noreply, push_patch(socket, to: ~p"/")}
    end
  end

  defp add_image_numbers(items) do
    item_count = Enum.count(items)

    images =
      @image_list
      |> Enum.shuffle()
      |> Enum.take(item_count)

    items
    |> Enum.with_index()
    |> Enum.reduce([], fn {item, index}, acc ->
      image_num = Enum.at(images, index)

      [{item, image_num} | acc]
    end)
    |> Enum.reverse()
  end

  defp setup_recommendation_engine(%{assigns: %{current_user: user}} = socket) do
    if connected?(socket) do
      username = user.name
      engine_name = engine_name(username)
      queue_name = queue_name(username)
      EngineQueueSupervisor.start_engine(engine_name, username)
      EngineQueueSupervisor.start_song_queue(queue_name, username)
      assign(socket, :queue_name, queue_name)
    else
      socket
    end
  end

  defp maybe_fetch_genres(
         %{assigns: %{current_user: user, capture_user_preferences?: capture_preferences?}} =
           socket
       ) do
    genres = if capture_preferences?, do: Genres.get_user_genres(user.name), else: []

    assign(socket, :genres, genres)
  end

  defp engine_name(username), do: "#{username}_recommendation_engine"

  defp queue_name(username), do: "#{username}_song_queue"
end
