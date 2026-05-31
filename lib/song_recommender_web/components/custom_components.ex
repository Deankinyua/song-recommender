defmodule SongRecommenderWeb.CustomComponents do
  @moduledoc """
  Custom components
  """

  use SongRecommenderWeb, :html

  alias SongRecommender.Artists.Artist
  alias SongRecommender.Songs.Song

  @type assigns :: map()
  @type rendered :: Phoenix.LiveView.Rendered.t()

  @spec anime(assigns()) :: rendered()
  def anime(assigns) do
    ~H"""
    <div class="hidden lg:flex flex-col items-center justify-center bg-base-200 p-12 text-primary-content relative overflow-hidden">
      <div class="relative z-10 text-center">
        <div class="avatar mb-8">
          <div class="w-64 h-64 rounded-full ring ring-secondary ring-offset-base-100 ring-offset-2">
            <img src={~p"/images/anime.jpeg"} alt="Onboarding visual" class="object-cover" />
          </div>
        </div>
        <h2 class="text-4xl montserrat-semibold tracking-tighter mb-4">Discover Your Sound</h2>
      </div>
    </div>
    """
  end

  attr :name, :string, required: true

  @spec label(assigns()) :: rendered()
  def label(assigns) do
    ~H"""
    <label class="label">
      <span class="label-text montserrat-semibold">{@name}</span>
    </label>
    """
  end

  @spec blur_song_image(assigns()) :: rendered()
  def blur_song_image(assigns) do
    ~H"""
    <section class="blur-song-thumbnail"></section>
    """
  end

  @spec search(assigns()) :: rendered()
  def search(assigns) do
    ~H"""
    <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
      <g stroke-width="0"></g>
      <g stroke-linecap="round" stroke-linejoin="round"></g>
      <g>
        <g clip-path="url(#clip0_15_152)">
          <rect width="24" height="24" fill="currentBackgroundColor"></rect>

          <circle cx="10.5" cy="10.5" r="6.5" stroke="currentColor" stroke-linejoin="round"></circle>

          <path
            d="M19.6464 20.3536C19.8417 20.5488 20.1583 20.5488 20.3536 20.3536C20.5488 20.1583 20.5488 19.8417 20.3536 19.6464L19.6464 20.3536ZM20.3536 19.6464L15.3536 14.6464L14.6464 15.3536L19.6464 20.3536L20.3536 19.6464Z"
            fill="currentColor"
          >
          </path>
        </g>

        <defs>
          <clipPath id="clip0_15_152">
            <rect width="24" height="24" fill="white"></rect>
          </clipPath>
        </defs>
      </g>
    </svg>
    """
  end

  attr :image, :integer, required: true
  attr :item, :any, required: true

  @spec search_item(assigns()) :: rendered()
  def search_item(assigns) do
    ~H"""
    <div class="search-item flex items-center gap-2 rounded-md py-2 px-2 mx-3 happy-monkey-regular hover:bg-accent hover:cursor-pointer">
      <section class="w-[3rem] h-[3rem] rounded-md relative overflow-hidden">
        <img
          src={path_to_image(@image)}
          alt="cover image"
          class="w-full h-full object-cover"
        />
        <section
          :if={check_if_song(@item)}
          class="searched-song-play-icon"
        >
          <.song_play_icon song={@item} />
        </section>

        <.blur_song_image />
      </section>
      <.item item={@item} />
    </div>
    """
  end

  @spec item(assigns()) :: rendered()
  def item(%{item: %Artist{} = _artist} = assigns) do
    ~H"""
    <section class="w-[47%] flex flex-col justify-center mx-2 gap-0">
      <div class="happy-monkey-bold">{@item.name}</div>
      <div class="text-sm">artist</div>
    </section>
    <section>
      <button
        id={"follow-#{@item.id}"}
        class={[
          "btn btn-secondary w-[7rem] h-[2rem] !rounded-full text-base-50",
          @item.following && "hidden"
        ]}
        phx-click={
          JS.push("follow_artist", value: %{artist: @item.name})
          |> toggle_follow_buttons(@item.id)
        }
      >
        Follow
      </button>

      <button
        id={"unfollow-#{@item.id}"}
        class={[
          "btn btn-secondary w-[7rem] h-[2rem] !rounded-full text-base-50",
          !@item.following && "hidden"
        ]}
        phx-click={
          JS.push("unfollow_artist", value: %{artist: @item.name})
          |> toggle_follow_buttons(@item.id)
        }
      >
        Unfollow
      </button>
    </section>
    """
  end

  def item(%{item: %Song{} = _song} = assigns) do
    ~H"""
    <section class="w-[90%] flex flex-col justify-center mx-2 gap-0">
      <div class="happy-monkey-bold">{maybe_trim_song_title(@item.name)}</div>
      <div class="text-sm">
        Song . <span class="happy-monkey-bold">{@item.artist.name}</span>
      </div>
    </section>
    """
  end

  @spec recent_searches(assigns()) :: rendered()
  def recent_searches(assigns) do
    ~H"""
    <div class="rounded-md py-2 px-2 mx-3 happy-monkey-regular">
      Recent searches
    </div>
    """
  end

  @spec song_progress_bar(assigns()) :: rendered()
  def song_progress_bar(assigns) do
    ~H"""
    <div class="w-[85%] flex items-center gap-3 mx-auto">
      <div id="song-played-time">---</div>

      <div class="w-[80%] flex justify-center">
        <input
          id="song-progress"
          type="range"
          min="0"
          max="240"
          step="0.01"
          value="0"
          class="w-full cursor-pointer"
        />
      </div>

      <div id="song-duration">---</div>
    </div>
    """
  end

  @spec back_icon(assigns()) :: rendered()
  def back_icon(assigns) do
    ~H"""
    <svg id="back-icon" width="36px" viewBox="0 0 36 36">
      <polygon
        id="back-polygon-1"
        points="
                    7, 10
                    8, 10
                    8, 26
                    7, 26
                  "
        fill="white"
      />
      <polygon
        id="back-polygon-2"
        points="
                28, 10
                11, 18
                11, 18
                28, 26
              "
        fill="white"
      />
    </svg>
    """
  end

  @spec next_icon(assigns()) :: rendered()
  def next_icon(assigns) do
    ~H"""
    <svg id="next-icon" width="36px" viewBox="0 0 36 36">
      <polygon
        id="next-polygon-1"
        points="
                    28, 10
                    29, 10
                    29, 26
                    28, 26
                  "
        fill="white"
      />

      <polygon
        id="next-polygon-2"
        points="
                8, 10
                25, 18
                25, 18
                8, 26
              "
        fill="white"
      />
    </svg>
    """
  end

  @doc """
  This is the smallest component in the play button and is the
  only part that is animated. It is the inner part without the circle.
  """

  attr :id, :string, required: true

  @spec play_icon(assigns()) :: rendered()
  def play_icon(assigns) do
    ~H"""
    <polygon
      id={"polygon-1-#{@id}"}
      points="
           11, 10
           11, 18
           11, 18
           11, 26
          "
      fill="white"
    />

    <polygon
      id={"polygon-2-#{@id}"}
      points="
            11, 10
            28, 18
            28, 18
            11, 26
          "
      fill="white"
    />
    """
  end

  @doc """
  This is the player icon. It is a full blown SVG and it has the inner part as well as
  the circle. Notice that it is the only one that has a hook `SongPlayer` attached.
  """

  attr :id, :string, required: true

  @spec player_play_icon(assigns()) :: rendered()
  def player_play_icon(assigns) do
    ~H"""
    <svg phx-hook="SongPlayer" id={@id} width="36" viewBox="0 0 36 36" fill="white">
      <circle cx="18" cy="18" r="17" class="play-btn-circle" />
      <.play_icon id={@id} />
    </svg>
    """
  end

  @doc """
  This is the icon placed on the left side of a song row for both searches and recommended songs.
  It is a full blown SVG but it only has the inner part (it does not have the circle).
  When you click it, an event will be sent to either pause/play the current song or play a new song.
  """

  attr :song, Song, required: true

  @spec song_play_icon(assigns()) :: rendered()
  def song_play_icon(assigns) do
    ~H"""
    <svg
      phx-hook="SongPlayIcon"
      id={@song.id}
      data-artist_id={@song.artist.id}
      data-artist_monthly_listeners={@song.artist.monthly_listeners}
      data-artist_name={@song.artist.name}
      data-duration_ms={@song.duration_ms}
      data-duration_played={0}
      data-genre_name={@song.genre.name}
      data-name={@song.name}
      width="30"
      viewBox="0 0 36 36"
      fill="white"
      class="w-full h-full object-cover"
    >
      <.play_icon id={@song.id} />
    </svg>
    """
  end

  attr :favourite_genre, :string, required: true

  @spec chat_bubble(assigns()) :: rendered()
  def chat_bubble(assigns) do
    ~H"""
    <svg
      width="22rem"
      viewBox="0 0 420 260"
      xmlns="http://www.w3.org/2000/svg"
    >
      <path
        d="
        M120 70
        C100 30, 180 20, 210 60
        C240 20, 320 30, 300 80
        C360 80, 380 150, 320 170
        C320 210, 230 230, 200 190
        C150 230, 90 210, 100 170
        C40 160, 50 90, 120 90
        Z
      "
        fill="#1a252f"
        stroke="white"
        stroke-width="3"
      />

      <circle cx="80" cy="190" r="10" fill="#1a252f" stroke="#111" stroke-width="3" />
      <circle cx="55" cy="215" r="6" fill="#1a252f" stroke="#111" stroke-width="3" />

      <text
        x="210"
        y="120"
        text-anchor="middle"
        font-size="14"
        fill="#5df8d8"
      >
        <tspan x="210" dy="0">
          I see that you listen
        </tspan>
        <tspan x="210" dy="24">
          to some {@favourite_genre} music.
        </tspan>
        <tspan x="210" dy="24">
          Just like me :)
        </tspan>
      </text>
    </svg>
    """
  end

  @spec spotify_logo(assigns()) :: rendered()
  def spotify_logo(assigns) do
    ~H"""
    <svg
      width="17"
      fill="#ffffff"
      viewBox="0 0 256 256"
      xmlns="http://www.w3.org/2000/svg"
      stroke="#ffffff"
    >
      <g stroke-width="0"></g>
      <g stroke-linecap="round" stroke-linejoin="round"></g>
      <g>
        <path d="M224,128a96,96,0,1,1-96-96A95.99991,95.99991,0,0,1,224,128Z" opacity="0.2"></path>

        <path d="M128,24A104,104,0,1,0,232,128,104.1179,104.1179,0,0,0,128,24Zm0,192a88,88,0,1,1,88-88A88.09957,88.09957,0,0,1,128,216Zm58.24805-104.01368a8.00024,8.00024,0,0,1-10.77246,3.458,104.1903,104.1903,0,0,0-95.03614.04492,8,8,0,1,1-7.3291-14.22265,120.19311,120.19311,0,0,1,109.68066-.05274A7.99973,7.99973,0,0,1,186.24805,111.98629Zm-14.82666,28.36426a8.00153,8.00153,0,0,1-10.76221,3.49024,71.9412,71.9412,0,0,0-65.40234.042,7.99976,7.99976,0,1,1-7.29-14.24219,87.94,87.94,0,0,1,79.96484-.05176A7.9994,7.9994,0,0,1,171.42139,140.35055ZM156.624,168.65719a8.00044,8.00044,0,0,1-10.73633,3.56641,39.98258,39.98258,0,0,0-35.85156.04,7.99966,7.99966,0,1,1-7.20117-14.28711,55.97479,55.97479,0,0,1,50.22217-.05566A7.99977,7.99977,0,0,1,156.624,168.65719Z">
        </path>
      </g>
    </svg>
    """
  end

  attr :image, :integer, required: true
  attr :song, Song, required: true

  @spec song(assigns()) :: rendered()
  def song(assigns) do
    ~H"""
    <section class="song rounded-md py-2 px-4 mx-3 flex justify-between items-center hover:bg-neutral hover:cursor-pointer">
      <div class="flex items-center gap-4">
        <section class="w-[1.6rem] flex flex-col items-center">
          <section class="song-number"></section>
          <section class="w-[20px] song-play-icon hidden">
            <.song_play_icon song={@song} />
          </section>
        </section>
        <section class="w-[3rem] h-[3rem] shrink-0 rounded-md overflow-hidden">
          <img src={path_to_image(@image)} alt="song image" class="w-full h-full object-cover" />
        </section>
        <section class="flex-1 flex flex-col">
          <p id={"song-name-#{@song.id}"}>{@song.name}</p>
          <p class="text-xs">{@song.artist.name}</p>
        </section>
      </div>

      <div class="flex gap-6 items-center">
        <section class="happy-monkey-bold">{milliseconds_to_minutes(@song.duration_ms)}</section>

        <.link
          href={"https://open.spotify.com/track/#{@song.id}"}
          target="_blank"
          referrerpolicy="noreferrer"
        >
          <.spotify_logo />
        </.link>
      </div>
    </section>
    """
  end

  attr :artist_image, :integer, required: true
  attr :song, Song, required: true

  @spec song_details(assigns()) :: rendered()
  def song_details(assigns) do
    ~H"""
    <section>
      <div
        :if={@song.id}
        class="w-[92%] mx-auto flex justify-between gap-2 items-center my-4"
      >
        <section class="w-[3.5rem] h-[3.5rem] rounded-md shrink-0 overflow-hidden">
          <img
            src={artist_image(@artist_image)}
            alt="artist image"
            class="w-full h-full object-cover"
          />
        </section>
        <section class="max-w-[75%] grow-1 flex flex-col gap-1 min-w-0 overflow-hidden">
          <.link
            id={"song-title-#{@song.id}"}
            href={"https://open.spotify.com/track/#{@song.id}"}
            target="_blank"
            referrerpolicy="noreferrer"
            class={[
              "montserrat-bold text-sm underline",
              should_translate_title?(@song.name) && "translate-song-title"
            ]}
          >
            {@song.name}
          </.link>

          <div class="text-xs">{@song.artist.name}</div>
        </section>
      </div>
    </section>
    """
  end

  defp milliseconds_to_minutes(milliseconds) do
    total_seconds = div(milliseconds, 1_000)

    minutes = div(total_seconds, 60)
    seconds = rem(total_seconds, 60)

    "#{minutes}:#{String.pad_leading("#{seconds}", 2, "0")}"
  end

  defp toggle_follow_buttons(js, id) do
    js
    |> JS.toggle(to: "#follow-#{id}")
    |> JS.toggle(to: "#unfollow-#{id}")
  end

  defp should_translate_title?(<<_title::binary-size(35), _rest::binary>>), do: true

  defp should_translate_title?(_title), do: false

  defp maybe_trim_song_title(<<title::binary-size(40), _rest::binary>>),
    do: title <> "..."

  defp maybe_trim_song_title(title), do: title

  defp check_if_song(item), do: Map.get(item, :artist)

  defp path_to_image(num), do: ~p"/images/songs/" <> "image_#{num}.jpeg"

  defp artist_image(image), do: ~p"/images/artists/artist_" <> "#{image}.jpeg"
end
