defmodule LeadfootWeb.Components.CarHeader do
  @moduledoc """
  Shows make, model, category and PI class of the current car.
  """

  use LeadfootWeb, :live_component

  @impl true
  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="text-right">
      <span class="bg-red-500 text-white">A800</span> Make Model AWD Car Category
    </div>
    """
  end
end
