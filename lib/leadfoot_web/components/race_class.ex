defmodule LeadfootWeb.Components.RaceClass do
  @moduledoc """
  Displays a Race class, like A800, using Forza Horizon colors.
  """

  use LeadfootWeb, :live_component

  def car_class_color(car_class) do
    case car_class do
      0 -> "bg-[#71c3e6]"
      1 -> "bg-[#fbc538]"
      2 -> "bg-[#ee621c]"
      3 -> "bg-[#e83354]"
      4 -> "bg-[#a75dc3]"
      5 -> "bg-[#1e5dd4]"
      6 -> "bg-green-500"
      _ -> "bg-black"
    end
  end

  def car_class(index) do
    Leadfoot.Translation.car_class(index)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <span class={"#{car_class_color(@car_class)} text-white"}>
      <%= car_class(@car_class) %><%= @car_performance %>
    </span>
    """
  end
end
