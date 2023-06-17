defmodule PtolemyWeb.Router do
  use PtolemyWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {PtolemyWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  # For when I have an auth plug
  # pipeline :auth do
  #   plug PtolemyWeb.Authentication
  # end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PtolemyWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/login", LoginController, :index
    get "/signup", SignupController, :index
    get "/verify", VerifyController, :index
  end

  # scope "/api", PtolemyWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:ptolemy, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: PtolemyWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
