defmodule SongRecommenderWeb.Songs.GenresPopupComponent do
  @moduledoc """
  Captures user's genre preferences
  """

  use SongRecommenderWeb, :live_component

  alias SongRecommender.Accounts
  alias SongRecommender.Genres
  alias SongRecommenderWeb.CustomComponents

  @genres Application.compile_env!(:song_recommender, :genres)

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div id="genre-preferences-popup" class="happy-monkey-regular" phx-hook="GenrePreferencesPopup">
      <.modal show={@show_modal?} id="capture-user-preferences-modal">
        <.form
          :if={!@submitted?}
          id={@id}
          for={@form}
          phx-target={@myself}
          phx-submit="submit_genres"
          class="px-4 py-4 bg-base-300 flex flex-col gap-4"
        >
          <div>What types of music do you like? Select all that apply:</div>
          <div>
            <.checkgroup field={@form[:genres]} options={@genres} />
          </div>
          <div class="mt-2 flex justify-between">
            <section :if={@show_error?} class="text-error">
              You must select at least one genre.
            </section>

            <button class="btn btn-primary h-[2rem] !rounded-full">
              Set Preferences
            </button>
          </div>
        </.form>

        <section :if={@submitted?} class="flex justify-center">
          <div class="w-[20rem]">
            <img
              src={~p"/images/boy_listening.png"}
              alt="cover image"
              class="w-full h-full object-cover"
            />
          </div>
          <div class="flex flex-col justify-center items-center gap-[6rem]">
            <div>
              <CustomComponents.chat_bubble favourite_genre={@favourite_genre} />
            </div>

            <div>
              <button
                phx-click={
                  hide_modal("capture-user-preferences-modal")
                  |> JS.dispatch("hide_genre_preferences_popup", to: "#genre-preferences-popup")
                  |> JS.push("complete_preferences_capture", target: @myself)
                }
                class="btn btn-primary h-[2rem] !rounded-full"
              >
                Start Listening
              </button>
            </div>
          </div>
        </section>
      </.modal>
    </div>
    """
  end

  @impl Phoenix.LiveComponent
  def update(%{user: user} = assigns, socket) do
    {:ok,
     socket
     |> assign_form(user)
     |> assign(:favourite_genre, "")
     |> assign(:genres, @genres)
     |> assign(:show_error?, false)
     |> assign(:submitted?, false)
     |> assign(assigns)}
  end

  @impl Phoenix.LiveComponent
  def handle_event("submit_genres", params, %{assigns: %{user: user}} = socket) do
    case Enum.empty?(params) do
      true ->
        {:noreply, assign(socket, :show_error?, true)}

      false ->
        %{"user" => %{"genres" => genres}} = params

        [favourite_genre | _other_genres] = genres

        changeset = Accounts.change_user_registration(user, params)
        updated_user = maybe_prefer_some_genres(changeset.valid?, user, genres)

        {:noreply,
         socket
         |> assign(:favourite_genre, favourite_genre)
         |> assign(:submitted?, true)
         |> assign(:user, updated_user)}
    end
  end

  def handle_event("complete_preferences_capture", _params, %{assigns: %{user: user}} = socket) do
    send(self(), {:updated_user, user})

    {:noreply, socket}
  end

  defp maybe_prefer_some_genres(true, user, genres), do: Genres.prefer_genres(user.name, genres)

  defp maybe_prefer_some_genres(false, user, _genres), do: user

  defp assign_form(socket, user) do
    form =
      user
      |> Accounts.change_user_registration()
      |> to_form(as: :user)

    assign(socket, :form, form)
  end
end
