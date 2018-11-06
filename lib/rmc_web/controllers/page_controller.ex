defmodule RmcWeb.PageController do
  use RmcWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
