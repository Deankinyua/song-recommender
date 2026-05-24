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
          class="play-song-icon"
        >
          <.song_play_icon />
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
      <button class="btn btn-secondary w-[7rem] h-[2rem] text-base-50 !rounded-full">
        Follow
      </button>
    </section>
    """
  end

  def item(%{item: %Song{} = _song} = assigns) do
    ~H"""
    <section class="w-[90%] flex flex-col justify-center mx-2 gap-0">
      <div class="happy-monkey-bold">{@item.name}</div>
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
      <div id="song-played-time">0:00</div>

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

      <div id="song-duration">4:00</div>
    </div>
    """
  end

  @spec back_icon(assigns()) :: rendered()
  def back_icon(assigns) do
    ~H"""
    <svg
      fill="#ffffff"
      width="20px"
      version="1.1"
      xmlns="http://www.w3.org/2000/svg"
      xmlns:xlink="http://www.w3.org/1999/xlink"
      viewBox="0 0 512.005 512.005"
      xml:space="preserve"
    >
      <g id="SVGRepo_bgCarrier_1" stroke-width="0"></g>
      <g id="SVGRepo_tracerCarrier_1" stroke-linecap="round" stroke-linejoin="round"></g>
      <g id="SVGRepo_iconCarrier_1">
        <g>
          <g>
            <path d="M490.861,2.971c-6.485-3.84-14.507-3.968-21.141-0.32L53.336,231.664V21.338c0-11.776-9.557-21.333-21.333-21.333 S10.669,9.562,10.669,21.338v469.333c0,11.776,9.557,21.333,21.333,21.333s21.333-9.557,21.333-21.333V280.346L469.72,509.36 c3.221,1.771,6.741,2.645,10.283,2.645c3.755,0,7.531-1.003,10.859-2.965c6.507-3.84,10.475-10.837,10.475-18.368V21.338 C501.336,13.786,497.368,6.81,490.861,2.971z">
            </path>
          </g>
        </g>
      </g>
    </svg>
    """
  end

  @spec next_icon(assigns()) :: rendered()
  def next_icon(assigns) do
    ~H"""
    <svg
      fill="#ffffff"
      width="20px"
      version="1.1"
      xmlns="http://www.w3.org/2000/svg"
      xmlns:xlink="http://www.w3.org/1999/xlink"
      viewBox="0 0 512 512"
      xml:space="preserve"
    >
      <g id="SVGRepo_bgCarrier_2" stroke-width="0"></g>
      <g id="SVGRepo_tracerCarrier_2" stroke-linecap="round" stroke-linejoin="round"></g>
      <g id="SVGRepo_iconCarrier_2">
        <g>
          <g>
            <path d="M480,0c-11.776,0-21.333,9.557-21.333,21.333v210.325L42.283,2.645c-6.613-3.627-14.656-3.52-21.141,0.32 c-6.485,3.84-10.475,10.816-10.475,18.368v469.333c0,7.552,3.989,14.528,10.475,18.368C24.491,511.019,28.245,512,32,512 c3.541,0,7.083-0.875,10.283-2.645l416.384-229.013v210.325c0,11.776,9.557,21.333,21.333,21.333s21.333-9.557,21.333-21.333 V21.333C501.333,9.557,491.776,0,480,0z">
            </path>
          </g>
        </g>
      </g>
    </svg>
    """
  end

  @spec skip_icon(assigns()) :: rendered()
  def skip_icon(assigns) do
    ~H"""
    <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
      <g id="SVGRepo_bgCarrier_3" stroke-width="0"></g>
      <g id="SVGRepo_tracerCarrier_3" stroke-linecap="round" stroke-linejoin="round"></g>
      <g id="SVGRepo_iconCarrier_3">
        <path d="M2 18.3429L10.7429 12.1714L2 6V18.3429Z" fill="#ffffff"></path>

        <path
          fill-rule="evenodd"
          clip-rule="evenodd"
          d="M20 12.1714L11.2571 18.3429V6L20 12.1714ZM20 12.1714V6H22V18H20V12.1714Z"
          fill="#ffffff"
        >
        </path>
      </g>
    </svg>
    """
  end

  @spec play_icon(assigns()) :: rendered()
  def play_icon(assigns) do
    ~H"""
    <polygon
      id="polygon-1"
      points="
           11, 10
           11, 18
           11, 18
           11, 26
          "
      fill="white"
    />

    <polygon
      id="polygon-2"
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

  @spec player_play_icon(assigns()) :: rendered()
  def player_play_icon(assigns) do
    ~H"""
    <svg id="pause-play" width="36" viewBox="0 0 36 36" fill="white">
      <circle cx="18" cy="18" r="17" class="play-btn-circle" />
      <.play_icon />
    </svg>
    """
  end

  @spec song_play_icon(assigns()) :: rendered()
  def song_play_icon(assigns) do
    ~H"""
    <svg
      id="pause-play"
      width="30"
      viewBox="0 0 36 36"
      fill="white"
      class="w-full h-full object-cover"
    >
      <.play_icon />
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
        fill="white"
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
  attr :song_number, :integer, required: true

  @spec song(assigns()) :: rendered()
  def song(assigns) do
    ~H"""
    <section class="song rounded-md py-2 px-4 mx-3 flex justify-between items-center hover:bg-neutral hover:cursor-pointer">
      <div class="flex items-center gap-4">
        <section class="w-[1.6rem] flex flex-col items-center">
          <section class="song-number">{@song_number}</section>
          <section class="w-[20px] song-play-icon hidden">
            <.song_play_icon />
          </section>
        </section>
        <section class="w-[3rem] h-[3rem] rounded-md overflow-hidden">
          <img src={path_to_image(@image)} alt="song image" class="object-cover" />
        </section>
        <section class="flex flex-col">
          <p>{@song.name}</p>
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

  def milliseconds_to_minutes(milliseconds) do
    total_seconds = div(milliseconds, 1_000)

    minutes = div(total_seconds, 60)
    seconds = rem(total_seconds, 60)

    "#{minutes}:#{String.pad_leading("#{seconds}", 2, "0")}"
  end

  defp check_if_song(item), do: Map.get(item, :artist)

  defp path_to_image(num), do: ~p"/images/songs/" <> "image_#{num}.jpeg"
end
