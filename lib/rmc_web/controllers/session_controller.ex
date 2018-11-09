defmodule RmcWeb.SessionController do
  use RmcWeb, :controller

  def index(conn, _params) do
    session = Rmc.Screens.Session.get()
    render(conn, "index.json", session_screen: session)
  end
end
