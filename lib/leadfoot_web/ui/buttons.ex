defmodule LeadfootWeb.UI.Buttons do
  @moduledoc false
  use Phoenix.Component

  def btn(assigns) do
    assigns =
      assigns
      |> assign_new(:class, fn -> "" end)
      |> assign_new(:type, fn -> "button" end)

    class = "bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded #{assigns.class}"

    ~H"""
    <button class={@class} type={@type}>
      <%= render_slot(@inner_block) %>
    </button>
    """
  end
end
