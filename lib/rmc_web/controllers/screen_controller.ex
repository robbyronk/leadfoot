defmodule RmcWeb.ScreenController do
  use RmcWeb, :controller

  def session(conn, _params) do
    session = Rmc.Screens.Session.get()
    render(conn, "index.json", screen_data: session)
  end

  def timing(conn, _params) do
    timing = Rmc.Screens.Timing.get()
    render(conn, "index.json", screen_data: timing)
  end
end
