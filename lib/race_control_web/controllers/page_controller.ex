defmodule RaceControlWeb.PageController do
  use RaceControlWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
