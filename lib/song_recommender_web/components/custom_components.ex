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
    <div class="hidden lg:flex flex-col items-center justify-center bg-primary p-12 text-primary-content relative overflow-hidden">
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

  @spec genre(assigns()) :: rendered()
  def genre(assigns) do
    ~H"""
    <div>
      <section class="flex items-center">
        <section class="w-[18%]">Hip-hop</section>
        <section class="w-[18%]">100030</section>
        <section>
          <.button class="btn btn-secondary-200 text-sm p-5">
            Follow
          </.button>
        </section>
      </section>
    </div>
    <div class="divider max-w-[90%] my-0"></div>
    """
  end

  @spec search(assigns()) :: rendered()
  def search(assigns) do
    ~H"""
    <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
      <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
      <g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g>
      <g id="SVGRepo_iconCarrier">
        <g clip-path="url(#clip0_15_152)">
          <rect width="24" height="24" fill="currentBackgroundColor"></rect>

          <circle cx="10.5" cy="10.5" r="6.5" stroke="#000000" stroke-linejoin="round"></circle>

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

  @spec search(assigns()) :: rendered()
  def search_item(%{item: %Artist{} = _artist} = assigns) do
    ~H"""
    <div>{@item.name}</div>
    """
  end

  def search_item(%{item: %Song{} = _song} = assigns) do
    ~H"""
    <div>{@item.name}</div>
    """
  end
end
