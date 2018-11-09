defmodule RmcWeb.SessionView do
  use RmcWeb, :view

  def render("index.json", %{session_screen: session}) do
    %{session: session}
  end
end
