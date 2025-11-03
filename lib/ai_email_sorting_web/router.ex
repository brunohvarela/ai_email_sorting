defmodule AiEmailSortingWeb.Router do
  use AiEmailSortingWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {AiEmailSortingWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug AiEmailSortingWeb.Plugs.FetchCurrentUser
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AiEmailSortingWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/auth/google", AuthController, :request
    get "/auth/google/callback", AuthController, :callback
    delete "/logout", AuthController, :delete

    live_session :require_authenticated_user,
      on_mount: [{AiEmailSortingWeb.UserAuth, :ensure_authenticated}] do
      live "/categories", CategoryLive.Index, :index
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", AiEmailSortingWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:ai_email_sorting, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: AiEmailSortingWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
