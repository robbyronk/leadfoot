defmodule LeadfootWeb.Components.DataSetup do
  @moduledoc """
  The DataSetup component show the status of the UDP connection and allows the user to turn it on and off.
  """

  use LeadfootWeb, :live_component

  @impl true
  def update(assigns, socket) do
    %{port: port} = Leadfoot.ReadUdp.status()

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:port, port)}
  end

  def render(assigns) do
    ~H"""
    <div>
      Data Port <%= @port %>
    </div>
    """
  end
end
