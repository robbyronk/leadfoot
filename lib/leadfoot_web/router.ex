defmodule LeadfootWeb.Router do
  use LeadfootWeb, :router

  import Phoenix.LiveDashboard.Router
  import LeadfootWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {LeadfootWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LeadfootWeb do
    pipe_through :browser

    get "/", PageController, :home

    live "/dyno", DynometerLive.View, :view
    live "/gear-ratios", GearRatiosLive.View, :view
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

#      live_dashboard "/server-dashboard", metrics: LeadfootWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", LeadfootWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{LeadfootWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", LeadfootWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{LeadfootWeb.UserAuth, :ensure_authenticated}] do
      live "/dashboard", DashboardLive.View, :view

      live "/tuning/launch", Tuning.LaunchLive, :view

      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", LeadfootWeb do
    pipe_through [:browser, :require_admin_user]
    live_dashboard "/server-dashboard", metrics: LeadfootWeb.Telemetry


    live_session :require_admin_user,
      on_mount: [{LeadfootWeb.UserAuth, :ensure_authenticated}] do
    end
  end

  scope "/", LeadfootWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{LeadfootWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
