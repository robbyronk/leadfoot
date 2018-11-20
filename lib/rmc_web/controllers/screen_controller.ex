defmodule RmcWeb.ScreenController do
  use RmcWeb, :controller
  alias Rmc.RaceState

  def session(conn, _params) do
    session = RaceState.get_session()
    render(conn, "index.json", screen_data: session)
  end

  def timing(conn, _params) do
    timing = RaceState.get_timing()
    render(conn, "index.json", screen_data: timing)
  end
end
