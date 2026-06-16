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
            artist_image={@current_artist_image}
            song={@current_song}
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
            artist_image={@current_artist_image}
            current_user={@current_user}
            engine_name={@engine_name}
            song={@current_song}
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
     |> assign(:current_artist_image, nil)
     |> assign(:current_song, %Song{})
     |> assign(:current_song_count, 0)
     |> assign(:engine_name, nil)
     |> assign(:played_song_count, 0)
     |> maybe_fetch_genres()
     |> setup_recommendation_engine()
     |> stream_configure(:search_items, dom_id: &"search-item-#{elem(&1, 0).id}")
     |> stream_configure(:songs, dom_id: &"song-#{elem(&1, 0).id}")
     |> stream(:songs, [])}
  end

  @impl Phoenix.LiveView
  def handle_params(
        params,
        _url,
        %{assigns: %{current_song: current_song, current_user: user}} = socket
      ) do
    search_query = params["q"] || ""

    case search_query != "" do
      true ->
        search_items = Search.search_query(search_query, user.name)
        search_items_empty? = Enum.empty?(search_items)

        search_items_with_images =
          if search_items_empty?, do: [], else: add_image_numbers(search_items)

        {:noreply,
         socket
         |> assign(:empty_search?, search_items_empty?)
         |> assign(:search_query, search_query)
         |> assign(:show_recent_searches?, false)
         |> push_event("set_current_song_id_for_search", %{current_song_id: current_song.id})
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
        %{assigns: %{engine_name: engine, queue_name: queue}} = socket
      ) do
    :ok = SongQueue.reset_queue(queue)

    _result =
      case RecommendationEngine.maybe_change_taste_profile(engine) do
        {:ok, :profile_changed} ->
          send(self(), :get_initial_songs)

        {:error, :profile_should_not_change} ->
          :ok
      end

    {
      :noreply,
      socket
      |> assign(:capture_user_preferences?, false)
      |> assign(:current_song_count, 0)
      |> assign(:played_song_count, 0)
      |> stream(:songs, [], reset: true)
    }
  end

  def handle_event(
        "play_new_song",
        %{
          "artist_id" => artist_id,
          "artist_monthly_listeners" => artist_monthly_listeners,
          "artist_name" => artist_name,
          "genre_name" => genre_name,
          "id" => song_id,
          "previous_song_duration_played" => previous_song_duration_played
        } = params,
        %{
          assigns: %{current_song: previous_song, current_user: user, queue_name: queue}
        } = socket
      ) do
    following_artist? = Artists.check_following_status(user.name, artist_name)

    artist_attrs = %{
      "following" => following_artist?,
      "id" => artist_id,
      "monthly_listeners" => artist_monthly_listeners,
      "name" => artist_name
    }

    genre_attrs = %{
      "name" => genre_name
    }

    new_song =
      params
      |> Map.put("artist", artist_attrs)
      |> Map.put("genre", genre_attrs)
      |> form_current_song()

    song_player_data = return_song_player_data(new_song, true)

    previous_song_dom_id = "song-#{previous_song.id}"

    persist_song_history(queue, song_id, previous_song_duration_played)

    {:noreply,
     socket
     |> set_playing_song_image()
     |> assign(:current_song, new_song)
     |> push_event("maybe_play_song", song_player_data)
     |> push_event("set_current_song_id", %{current_song_id: new_song.id})
     |> push_event("pause_previous_song", %{previous_song_id: previous_song.id})
     |> stream_delete_by_dom_id(:songs, previous_song_dom_id)}
  end

  def handle_event(
        "play_next_song",
        %{"duration_played" => duration_played},
        %{
          assigns: %{
            current_song: current_song,
            current_song_count: song_count,
            engine_name: engine_name,
            played_song_count: played_song_count,
            queue_name: queue
          }
        } =
          socket
      ) do
    remaining_song_count = song_count - played_song_count
    song_id = current_song.id
    persist_song_history(queue, song_id, duration_played)
    song_dom_id = "song-#{song_id}"
    new_played_song_count = played_song_count + 1

    :ok = maybe_fetch_new_songs(engine_name, remaining_song_count)

    {:noreply,
     socket
     |> assign(:current_song_count, song_count - 1)
     |> assign(:played_song_count, new_played_song_count)
     |> push_event("play_next_song", %{})
     |> stream_delete_by_dom_id(:songs, song_dom_id)}
  end

  def handle_event(
        "should_recommend_new_songs",
        _params,
        %{assigns: %{current_song: song, engine_name: engine_name}} = socket
      ) do
    RecommendationEngine.recommend_with_song(engine_name, song)

    {:noreply, assign(socket, :current_song_count, 0)}
  end

  def handle_event(
        "change_genre_preferences",
        _params,
        %{assigns: %{current_user: user}} = socket
      ) do
    genres = Genres.get_user_genres(user.name)

    {:noreply,
     socket
     |> assign(:genres, genres)
     |> push_event("maybe_pause_song", %{})}
  end

  def handle_event(
        "follow_artist",
        %{"artist" => artist_name},
        %{assigns: %{current_user: user, engine_name: engine_name}} = socket
      ) do
    Artists.follow_artist(user.name, artist_name)
    :ok = RecommendationEngine.track_followed_artist(engine_name)
    {:noreply, socket}
  end

  def handle_event(
        "unfollow_artist",
        %{"artist" => artist_name},
        %{assigns: %{current_user: user, engine_name: engine_name}} = socket
      ) do
    Artists.unfollow_artist(user.name, artist_name)
    :ok = RecommendationEngine.track_unfollowed_artist(engine_name)
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

  def handle_info({:new_recommended_songs, []}, socket), do: {:noreply, socket}

  def handle_info(
        {:new_recommended_songs, recommended_songs},
        %{
          assigns: %{
            current_song: song,
            current_song_count: song_count
          }
        } = socket
      ) do
    new_song_count = song_count + Enum.count(recommended_songs)
    processed_recommended_songs = add_image_numbers(recommended_songs)

    {:noreply,
     socket
     |> assign(:current_song_count, new_song_count)
     |> assign(:played_song_count, 0)
     |> push_event("set_current_song_id", %{current_song_id: song.id})
     |> stream(:songs, processed_recommended_songs, at: -1, limit: -18)}
  end

  def handle_info(
        {:DOWN, ref, :process, _object, :normal},
        %{assigns: %{current_user: user, engine_name: engine, queue_name: queue}} =
          socket
      ) do
    username = user.name
    Process.demonitor(ref)
    {:ok, engine_pid} = EngineQueueSupervisor.start_engine(engine, username)
    _new_engine_ref = Process.monitor(engine_pid)
    EngineQueueSupervisor.start_song_queue(queue, username)
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_async(:get_songs, {:ok, songs}, socket) when songs == [], do: {:noreply, socket}

  def handle_async(
        :get_songs,
        {:ok, songs},
        %{assigns: %{current_song_count: song_count, current_user: user}} = socket
      ) do
    initial_song =
      songs
      |> Enum.at(0)
      |> Artists.set_artist_following_status(user.name)

    song_player_data = return_song_player_data(initial_song, false)

    new_song_count = song_count + Enum.count(songs)

    processed_songs = add_image_numbers(songs)

    {:noreply,
     socket
     |> set_playing_song_image()
     |> assign(:current_song, initial_song)
     |> assign(:current_song_count, new_song_count)
     |> push_event("maybe_play_song", song_player_data)
     |> push_event("set_current_song_id", %{current_song_id: initial_song.id})
     |> stream(:songs, processed_songs)}
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

  defp maybe_fetch_new_songs(engine, remaining_song_count)
       when remaining_song_count <= 10,
       do: RecommendationEngine.recommend_new_songs(engine)

  defp maybe_fetch_new_songs(_engine, _remaining_song_count), do: :ok

  defp persist_song_history(_queue, _song_id, nil), do: :ok

  defp persist_song_history(_queue, _song_id, 0), do: :ok

  defp persist_song_history(queue, song_id, duration_played) do
    duration_ms = trunc(duration_played * 1000)
    song_details = [song_id, duration_ms]
    SongQueue.persist_played_song(queue, song_details)
  end

  defp add_image_numbers(items) do
    images = return_thumbnails(items)

    items
    |> Enum.with_index()
    |> Enum.reduce([], fn {item, index}, acc ->
      image_num = Enum.at(images, index)

      [{item, image_num} | acc]
    end)
    |> Enum.reverse()
  end

  defp return_thumbnails(items) do
    item_count = Enum.count(items)

    @image_list
    |> Enum.shuffle()
    |> Stream.cycle()
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

      start_engine_and_queue(engine_name, queue_name, username)

      Songs.subscribe(username)

      if !capture_preferences?, do: Process.send_after(self(), :get_initial_songs, 1400)

      socket
      |> assign(:engine_name, engine_name)
      |> assign(:queue_name, queue_name)
    else
      socket
    end
  end

  defp start_engine_and_queue(engine_name, queue_name, username) do
    engine_pid =
      case EngineQueueSupervisor.start_engine(engine_name, username) do
        {:ok, engine_pid} -> engine_pid
        {:error, {:already_started, engine_pid}} -> engine_pid
      end

    Process.monitor(engine_pid)

    EngineQueueSupervisor.start_song_queue(queue_name, username)
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
    assign(socket, :current_artist_image, image_num)
  end

  defp form_current_song(song_attrs), do: Songs.populate_song(%Song{}, song_attrs)

  defp engine_name(username), do: "#{username}_recommendation_engine"

  defp queue_name(username), do: "#{username}_song_queue"
end
