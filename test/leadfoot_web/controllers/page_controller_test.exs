defmodule LeadfootWeb.PageControllerTest do
  use LeadfootWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Leadfoot"
  end
end
