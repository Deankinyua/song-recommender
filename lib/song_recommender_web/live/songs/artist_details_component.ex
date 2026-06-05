defmodule SongRecommenderWeb.Songs.ArtistDetailsComponent do
  @moduledoc """
  Holds the artist details on the rightmost pane.
  """

  use SongRecommenderWeb, :live_component

  alias SongRecommender.Artists
  alias SongRecommender.RecommendationEngine

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div class="flex flex-col justify-center gap-4 h-full">
      <section :if={@song.id} class="rounded-md overflow-hidden h-[60%]">
        <img
          src={artist_image(@artist_image)}
          alt="artist image"
          class="w-full h-full object-cover"
        />
      </section>
      <section :if={@song.id} class="flex flex-col gap-2">
        <div class="px-2 montserrat-bold">{@song.artist.name}</div>
        <div class="flex gap-2 justify-between px-2 text-sm items-center">
          <section>
            {@song.artist.monthly_listeners} monthly listeners
          </section>
          <section>
            <button
              :if={!@song.artist.following}
              class={[
                "btn btn-base-200 happy-monkey-regular w-[7rem] h-[2rem] text-base-100 !rounded-full"
              ]}
              phx-click={
                JS.push("follow_artist", value: %{artist: @song.artist.name}, target: @myself)
              }
            >
              Follow
            </button>

            <button
              :if={@song.artist.following}
              class={[
                "btn btn-base-200 happy-monkey-regular w-[7rem] h-[2rem] text-base-100 !rounded-full"
              ]}
              phx-click={
                JS.push("unfollow_artist", value: %{artist: @song.artist.name}, target: @myself)
              }
            >
              Unfollow
            </button>
          </section>
        </div>
      </section>
    </div>
    """
  end

  @impl Phoenix.LiveComponent
  def handle_event(
        "follow_artist",
        %{"artist" => artist_name},
        %{assigns: %{current_user: user, engine_name: engine, song: song}} = socket
      ) do
    Artists.follow_artist(user.name, artist_name)

    :ok = RecommendationEngine.track_followed_artist(engine)
    artist = %{song.artist | following: true}
    updated_song = %{song | artist: artist}

    {:noreply, assign(socket, :song, updated_song)}
  end

  def handle_event(
        "unfollow_artist",
        %{"artist" => artist_name},
        %{assigns: %{current_user: user, engine_name: engine, song: song}} = socket
      ) do
    Artists.unfollow_artist(user.name, artist_name)

    :ok = RecommendationEngine.track_unfollowed_artist(engine)
    artist = %{song.artist | following: false}
    updated_song = %{song | artist: artist}

    {:noreply, assign(socket, :song, updated_song)}
  end

  defp artist_image(image), do: ~p"/images/artists/artist_" <> "#{image}.jpeg"
end
