defmodule SongRecommenderWeb.Router do
  use SongRecommenderWeb, :router

  import SongRecommenderWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {SongRecommenderWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Other scopes may use custom stacks.
  # scope "/api", SongRecommenderWeb do
  #   pipe_through :api
  # end

  scope "/", SongRecommenderWeb do
    pipe_through [:browser]

    delete "/sign-out", UserSessionController, :log_out
    post "/sign-in", UserSessionController, :create
  end

  scope "/", SongRecommenderWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{SongRecommenderWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/sign-up", AuthLive.SignUp, :new
      live "/sign-in", AuthLive.SignIn, :new
    end
  end

  scope "/", SongRecommenderWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{SongRecommenderWeb.UserAuth, :ensure_authenticated}] do
      live "/", SongsLive.Index, :index
      live "/genres", GenresLive.Index, :index
    end
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:song_recommender, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: SongRecommenderWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
