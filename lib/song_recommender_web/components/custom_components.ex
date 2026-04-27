defmodule SongRecommenderWeb.CustomComponents do
  @moduledoc """
  Custom components
  """

  use SongRecommenderWeb, :html

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
end
