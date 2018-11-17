defmodule RmcWeb.Router do
  use RmcWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", RmcWeb do
    pipe_through :api

    get "/session", ScreenController, :session
    get "/timing", ScreenController, :timing
  end

  scope "/", RmcWeb do
    pipe_through :browser

    get "/*path", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", RmcWeb do
  #   pipe_through :api
  # end
end
