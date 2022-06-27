defmodule LeadfootWeb.GearRatiosLive.View do
  @moduledoc false
  use LeadfootWeb, :live_view
  alias Phoenix.PubSub
  alias Leadfoot.GearRatios
  import Leadfoot.SampleEvent
  import Leadfoot.Translation

  @initial_assigns %{
    event: nil,
    recording: false,
    torque_plot: "",
    force_plot: "",
    torques: []
  }

  @impl true
  def mount(_params, session, socket) do
    PubSub.subscribe(Leadfoot.PubSub, "session")
    Process.send_after(self(), :get_torques, 1000)

    {
      :ok,
      socket
      |> assign(@initial_assigns)
    }
  end

  def handle_info({:event, event}, socket) do
    {
      :noreply,
      socket
      |> set_assigns(event)
    }
  end

  def handle_info(:get_torques, socket) do
    %{recording: recording, torques: torques} = GearRatios.get_torques()
    forces = GearRatios.get_wheel_forces()
    Process.send_after(self(), :get_torques, 1000)

    {
      :noreply,
      socket
      |> assign(torque_plot: torque_plot(torques))
      |> assign(force_plot: force_plot(forces))
      |> assign(recording: recording)
    }
  end

  def set_assigns(socket, event) do
    socket
    |> assign(:event, event)
  end

  def torque_plot([]), do: ""

  def torque_plot(torques) do
    torques
    |> Contex.Dataset.new()
    |> Contex.Plot.new(Contex.PointPlot, 600, 400)
    |> Contex.Plot.to_svg()
  end

  def force_plot([]), do: ""

  def force_plot(forces) do
    forces
    |> Contex.Dataset.new()
    |> Contex.Plot.new(Contex.PointPlot, 600, 400)
    |> Contex.Plot.to_svg()
  end
end
