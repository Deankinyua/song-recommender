defmodule SongRecommenderWeb.AuthLive.SignIn do
  use SongRecommenderWeb, :live_view
  use SongRecommenderWeb, :setup_aliases

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <Layouts.main flash={@flash}>
      <div class="min-h-screen flex items-center justify-center p-4">
        <div class="min-h-[80vh] grid grid-cols-1 bg-base-100 shadow-2xl rounded-3xl overflow-hidden max-w-[80rem] gap-8 w-full lg:grid-cols-2">
          <CustomComponents.anime />

          <div class="p-4 flex flex-col justify-center md:p-6">
            <div class="mb-4 text-center lg:text-left">
              <h1 class="text-3xl font-bold mb-2">Sign In</h1>
              <p class="text-base-content/60">
                New here?
                <.link
                  navigate={~p"/sign-up"}
                  class="link link-primary no-underline font-semibold hover:underline"
                >
                  Register
                </.link>
              </p>
            </div>

            <.form
              for={@form}
              id="login_form"
              action={~p"/sign-in"}
              phx-update="ignore"
              class="space-y-4 relative py-6"
            >
              <div class="form-control">
                <CustomComponents.label name="Username" />

                <.input
                  field={@form[:name]}
                  type="text"
                  placeholder="Durant"
                  required
                  class="input input-bordered w-[70%] focus:input-primary"
                />
              </div>

              <div class="w-[7rem] mt-10">
                <.button
                  phx-disable-with="Logging you in..."
                  class="btn btn-primary btn-block shadow-lg py-5"
                  type="submit"
                >
                  Log in
                </.button>
              </div>
            </.form>
          </div>
        </div>
      </div>
    </Layouts.main>
    """
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    form =
      %User{}
      |> Accounts.change_user_registration()
      |> to_form(as: :user)

    {:ok, assign(socket, :form, form), temporary_assigns: [form: form]}
  end
end
