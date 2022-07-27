defmodule LeadfootWeb.UI.Buttons do
  use Phoenix.Component

  def btn(assigns) do
    assigns = assign_new(assigns, :class, fn -> "" end)
    assigns = assign_new(assigns, :type, fn -> "button" end)

    class =
      "bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded #{assigns.class}"

    ~H"""
    <button class={class} type={@type}>
      <%= render_slot(@inner_block) %>
    </button>
    """
  end
end
