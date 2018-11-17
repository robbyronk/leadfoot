defmodule RmcWeb.ScreenView do
  use RmcWeb, :view

  def render("index.json", %{screen_data: data}) do
    %{data: data}
  end
end
