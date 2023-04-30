defmodule LeadfootWeb.Router do
  use LeadfootWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {LeadfootWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LeadfootWeb do
    pipe_through :browser

    get "/", PageController, :home

    live "/dyno", DynometerLive.View, :view
    live "/gear-ratios", GearRatiosLive.View, :view
    live "/dashboard", DashboardLive.View, :view
    live "/lap-times", LapTimesLive.View, :view
    live "/suspension", SuspensionCalculatorLive.View, :view
  end

  # Other scopes may use custom stacks.
  # scope "/api", LeadfootWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:leadfoot, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/server-dashboard", metrics: LeadfootWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
