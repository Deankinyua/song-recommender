defmodule SongRecommenderWeb.SongsLive.Index do
  use SongRecommenderWeb, :live_view
  use SongRecommenderWeb, :setup_homepage_aliases

  @image_list 1..15
  @no_playing_song_images 10

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} class="bg-base-50" username={@current_user.name}>
      <div class="h-[92vh] flex text-base-100">
        <section class="flex flex-col justify-end w-[22%] relative h-[90%] my-6 rounded-xl bg-base-70">
          <CustomComponents.song_details
            artist_image={@currently_playing_artist_image}
            song={@currently_playing_song}
          />

          <.live_component
            id="genres-popup-component"
            module={GenresPopupComponent}
            user_genres={@genres}
            show_modal?={@capture_user_preferences?}
            user={@current_user}
          />
        </section>
        <section class="flex-1 flex flex-col items-center gap-2">
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
            songs={@streams.songs}
          />

          <.live_component
            id="player-component"
            module={PlayerComponent}
          />
        </section>

        <section class="w-[22%] h-[90%] my-6 rounded-xl bg-base-70">
          <.live_component
            id="artist-details-component"
            module={ArtistDetailsComponent}
            current_user={@current_user}
            artist_image={@currently_playing_artist_image}
            song={@currently_playing_song}
          />
        </section>
      </div>
    </Layouts.app>
    """
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:currently_playing_song, %Song{})
     |> assign(:currently_playing_artist_image, nil)
     |> assign(:song_count, 0)
     |> maybe_fetch_genres()
     |> setup_recommendation_engine()
     |> stream_configure(:search_items, dom_id: &"search-item-#{elem(&1, 0).id}")
     |> stream_configure(:songs, dom_id: &"song-#{elem(&1, 0).id}")
     |> stream(:songs, [])}
  end

  @impl Phoenix.LiveView
  def handle_params(params, _url, %{assigns: %{current_user: user}} = socket) do
    search_query = params["q"] || ""

    case search_query != "" do
      true ->
        search_items = Search.search_query(search_query, user.name)
        search_items_empty? = Enum.empty?(search_items)

        search_items_with_images =
          if search_items_empty?, do: [], else: maybe_add_song_numbers(search_items, :search_item)

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

  def handle_event(
        "maybe_refetch_recommended_songs",
        _params,
        %{assigns: %{engine_name: engine}} = socket
      ) do
    _result =
      case RecommendationEngine.maybe_change_taste_profile(engine) do
        {:ok, :profile_changed} ->
          send(self(), :get_initial_songs)

        {:error, :profile_should_not_change} ->
          :ok
      end

    {:noreply, socket}
  end

  def handle_event(
        "play_or_pause_song",
        %{
          "artist" => artist_name,
          "artist_monthly_listeners" => artist_listeners,
          "duration" => duration_ms,
          "genre" => genre,
          "id" => id,
          "song_name" => song_name
        },
        %{assigns: %{currently_playing_song: current_song, current_user: user}} = socket
      ) do
    case id == current_song.id do
      true ->
        {:noreply, push_event(socket, "play_or_pause_song", %{})}

      false ->
        following_artist? = Artists.check_following_status(user.name, artist_name)

        artist = %Artist{
          following: following_artist?,
          name: artist_name,
          listeners: artist_listeners
        }

        genre = %Genre{name: genre}

        new_song = %Song{
          artist: artist,
          duration_ms: duration_ms,
          genre: genre,
          id: id,
          name: song_name
        }

        song_player_data = return_song_player_data(new_song, true)

        {:noreply,
         socket
         |> set_playing_song_image()
         |> assign(:currently_playing_song, new_song)
         |> push_event("maybe_play_song", song_player_data)
         |> push_event("pause_previous_song", %{previous_song_id: current_song.id})}
    end
  end

  def handle_event(
        "follow_artist",
        %{"artist" => artist_name},
        %{assigns: %{current_user: user}} = socket
      ) do
    Artists.follow_artist(user.name, artist_name)
    {:noreply, socket}
  end

  def handle_event(
        "unfollow_artist",
        %{"artist" => artist_name},
        %{assigns: %{current_user: user}} = socket
      ) do
    Artists.unfollow_artist(user.name, artist_name)
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_info(:get_initial_songs, %{assigns: %{queue_name: queue}} = socket) do
    socket =
      start_async(socket, :get_songs, fn ->
        SongQueue.get_recommended_songs(queue)
      end)

    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_async(
        :get_songs,
        {:ok, songs},
        %{assigns: %{current_user: user, song_count: count}} = socket
      ) do
    initial_song =
      songs
      |> Enum.at(0)
      |> Artists.set_artist_following_status(user.name)

    song_player_data = return_song_player_data(initial_song, false)

    processed_songs = maybe_add_song_numbers(songs, :song, count)

    {_last_song, _last_song_image, new_song_count} = Enum.at(processed_songs, -1)

    {:noreply,
     socket
     |> set_playing_song_image()
     |> assign(:currently_playing_song, initial_song)
     |> assign(:song_count, new_song_count)
     |> push_event("maybe_play_song", song_player_data)
     |> stream(:songs, processed_songs, reset: true)}
  end

  defp return_song_player_data(song, should_play, current_time \\ 0) do
    duration_sec = div(song.duration_ms, 1000)

    %{
      current_song_duration: duration_sec,
      current_song_id: song.id,
      current_time: current_time,
      should_play: should_play
    }
  end

  defp maybe_add_song_numbers(items, item_type, current_song_count \\ 0)

  defp maybe_add_song_numbers(search_items, :search_item, _current_song_count) do
    images = return_thumbnails(search_items)

    search_items
    |> Enum.with_index()
    |> Enum.reduce([], fn {search_item, index}, acc ->
      image_num = Enum.at(images, index)

      [{search_item, image_num} | acc]
    end)
    |> Enum.reverse()
  end

  defp maybe_add_song_numbers(songs, :song, current_song_count) do
    images = return_thumbnails(songs)

    starting_number = current_song_count + 1

    songs
    |> Enum.with_index()
    |> Enum.reduce([], fn {song, index}, acc ->
      image_num = Enum.at(images, index)

      song_number = starting_number + index

      [{song, image_num, song_number} | acc]
    end)
    |> Enum.reverse()
  end

  defp return_thumbnails(items) do
    item_count = Enum.count(items)

    @image_list
    |> Enum.shuffle()
    |> Enum.take(item_count)
  end

  defp setup_recommendation_engine(
         %{assigns: %{capture_user_preferences?: capture_preferences?, current_user: user}} =
           socket
       ) do
    if connected?(socket) do
      username = user.name
      engine_name = engine_name(username)
      queue_name = queue_name(username)

      EngineQueueSupervisor.start_engine(engine_name, username)
      EngineQueueSupervisor.start_song_queue(queue_name, username)

      if !capture_preferences?, do: Process.send_after(self(), :get_initial_songs, 800)

      socket
      |> assign(:engine_name, engine_name)
      |> assign(:queue_name, queue_name)
    else
      socket
    end
  end

  defp maybe_fetch_genres(
         %{assigns: %{capture_user_preferences?: capture_preferences?, current_user: user}} =
           socket
       ) do
    genres = if capture_preferences?, do: Genres.get_user_genres(user.name), else: []

    assign(socket, :genres, genres)
  end

  defp set_playing_song_image(socket) do
    image_num = :rand.uniform(@no_playing_song_images)
    assign(socket, :currently_playing_artist_image, image_num)
  end

  defp engine_name(username), do: "#{username}_recommendation_engine"

  defp queue_name(username), do: "#{username}_song_queue"
end
