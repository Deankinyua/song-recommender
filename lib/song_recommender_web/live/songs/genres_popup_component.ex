defmodule SongRecommenderWeb.Songs.GenresPopupComponent do
  @moduledoc """
  Captures user's genre preferences
  """

  use SongRecommenderWeb, :live_component

  alias SongRecommender.Accounts

  @genres Application.compile_env!(:song_recommender, :genres)

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <.form
        for={@form}
        phx-target={@myself}
        phx-submit="submit_genres"
        class="min-w-[36rem] px-4 py-4 bg-base-300 rounded-xl flex flex-col gap-4 happy-monkey-regular absolute top-[8rem] left-[2rem]"
      >
        <div>What types of music do you like? Select all that apply:</div>
        <div>
          <.checkgroup field={@form[:genres]} options={@genres} />
        </div>
        <div class="mt-2 flex justify-between">
          <section :if={@show_error?} class="text-error">You must select at least one genre.</section>

          <button class="btn btn-primary h-[2rem] !rounded-full">
            Set Preferences
          </button>
        </div>
      </.form>
    </div>
    """
  end

  @impl Phoenix.LiveComponent
  def update(%{user: user} = assigns, socket) do
    {:ok,
     socket
     |> assign_form(user)
     |> assign(:genres, @genres)
     |> assign(:show_error?, false)
     |> assign(assigns)}
  end

  @impl Phoenix.LiveComponent
  def handle_event("submit_genres", params, socket) do
    case Enum.empty?(params) do
      true ->
        {:noreply, assign(socket, :show_error?, true)}

      false ->
        %{"user" => %{"genres" => genres}} = params
        {:noreply, socket}
    end
  end

  defp assign_form(socket, user) do
    form =
      user
      |> Accounts.change_user_registration()
      |> to_form(as: :user)

    assign(socket, :form, form)
  end
end
