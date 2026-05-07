defmodule SongRecommenderWeb.SongsLive.Index do
  use SongRecommenderWeb, :live_view

  alias SongRecommender.Search
  alias SongRecommenderWeb.Songs.SongsComponent

  @image_list 1..15

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="h-[92vh] flex">
        <section class="w-[25%] border border-red-400"></section>

        <.live_component
          id="songs-component"
          module={SongsComponent}
          search_items={@streams.search_items}
          search_query={@search_query}
        />

        <section class="w-[25%] border border-red-400"></section>
      </div>
    </Layouts.app>
    """
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:search_query, "")
     |> stream_configure(:search_items, dom_id: &"search-item-#{elem(&1, 0).id}")
     |> stream(:search_items, [])}
  end

  @impl Phoenix.LiveView
  def handle_params(params, _url, socket) do
    search_query = params["q"] || ""

    case search_query != "" do
      true ->
        search_items = Search.search_query(search_query)

        search_items_with_images =
          if Enum.empty?(search_items), do: [], else: add_image_numbers(search_items)

        {:noreply,
         socket
         |> assign(:search_query, search_query)
         |> stream(:search_items, search_items_with_images, reset: true)}

      false ->
        {:noreply, assign(socket, :search_query, "")}
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
end
