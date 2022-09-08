defmodule LeadfootWeb.DynometerLive.View do
  use LeadfootWeb, :live_view

  @initial_assigns %{
    event: nil,
    recording: false,
    torque_plot: "",
    torques: []
  }

  @impl true
  def mount(_params, _session, socket) do
    %{torques: torques, recording: recording} = Leadfoot.GearRatios.get_torques()

    Process.send_after(self(), :update_torques, 100)

    {
      :ok,
      socket
      |> assign(@initial_assigns)
      |> assign(torques: torques, recording: recording)
    }
  end

  @impl true
  def handle_event("start", _params, socket) do
    Leadfoot.GearRatios.start_recording()
    {:noreply, socket |> assign(recording: true)}
  end

  @impl true
  def handle_event("stop", params, socket) do
    Leadfoot.GearRatios.stop_recording()
    {:noreply, socket |> assign(recording: false)}
  end

  @impl true
  def handle_event("clear", _params, socket) do
    Leadfoot.GearRatios.clear_recording()
    {:noreply, socket |> assign(@initial_assigns)}
  end

  @impl true
  def handle_info(:update_torques, socket) do
    Process.send_after(self(), :update_torques, 100)
    %{torques: torques, recording: recording} = Leadfoot.GearRatios.get_torques()

    {:noreply,
     socket |> assign(torques: torques, recording: recording, torque_plot: plot(torques))}
  end

  def plot([]), do: ""

  def plot(data) do
    data
    |> Contex.Dataset.new()
    |> Contex.Plot.new(Contex.PointPlot, 600, 400)
    |> Contex.Plot.to_svg()
  end
end
