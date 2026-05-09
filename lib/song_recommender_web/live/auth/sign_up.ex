defmodule SongRecommenderWeb.AuthLive.SignUp do
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
            <div class="text-center lg:text-left">
              <h1 class="text-3xl font-bold mb-2">Create Account</h1>
              <p class="text-base-content/60">
                Already registered?
                <.link
                  navigate={~p"/sign-in"}
                  class="link link-primary no-underline montserrat-semibold hover:underline"
                >
                  Log in
                </.link>
              </p>
            </div>

            <.form
              for={@form}
              id="registration_form"
              phx-submit="save"
              phx-change="validate"
              phx-trigger-action={@trigger_submit}
              action={~p"/sign-in?_action=registered"}
              method="post"
              class="relative py-2"
            >
              <div class="form-control">
                <CustomComponents.label name="Username" />

                <.input
                  field={@form[:name]}
                  type="text"
                  placeholder="E.g Durant"
                  required
                  class="input input-bordered w-[70%] focus:input-primary"
                />
              </div>

              <div class="w-[10rem] mt-4">
                <.button
                  phx-disable-with="Creating account..."
                  class="btn btn-primary btn-block shadow-lg py-5"
                  type="submit"
                  disabled={!@form.source.valid?}
                >
                  Get Started
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
    changeset = Accounts.change_user_registration(%User{})

    socket =
      socket
      |> assign(:trigger_submit, false)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  @impl Phoenix.LiveView
  def handle_event("save", %{"user" => %{"name" => username} = user_params}, socket) do
    if Accounts.get_user!(username) do
      {:noreply, put_flash(socket, :info, "#{username} already exists, try logging in")}
    else
      Accounts.register_user(user_params)
      {:noreply, assign(socket, :trigger_submit, true)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)

    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")
    assign(socket, :form, form)
  end
end
