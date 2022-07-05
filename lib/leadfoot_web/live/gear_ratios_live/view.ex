defmodule LeadfootWeb.GearRatiosLive.View do
  @moduledoc false
  use LeadfootWeb, :live_view
  alias Phoenix.PubSub
  alias Leadfoot.GearRatios
  alias Leadfoot.ReadFile
  alias Leadfoot.CarSettings.Tires
  alias Leadfoot.CarSettings.Gearbox
  import Leadfoot.SampleEvent
  import Leadfoot.Translation

  @initial_assigns %{
    event: nil,
    recording: false,
    torque_plot: "",
    force_plot: "",
    torques: [],
    gearbox: %Gearbox{},
    gearbox_changeset: nil,
    tires: %Tires{},
    tires_changeset: nil,
    shift_points: []
  }

  @impl true
  def mount(_params, session, socket) do
    PubSub.subscribe(Leadfoot.PubSub, "session")
    Process.send_after(self(), :get_torques, 1000)

    {
      :ok,
      socket
      |> assign(@initial_assigns)
      |> assign_tires_changeset()
      |> assign_gearbox_changeset()
    }
  end

  def assign_tires_changeset(%{assigns: %{tires: tires}} = socket) do
    assign(socket, tires_changeset: Tires.changeset(tires, %{}))
  end

  def assign_gearbox_changeset(%{assigns: %{gearbox: gearbox}} = socket) do
    assign(socket, gearbox_changeset: Gearbox.changeset(gearbox, %{}))
  end

  @impl true
  def handle_info({:event, event}, %{assigns: %{event: last_event}} = socket) do
    if last_event == nil or event[:timestamp] > last_event[:timestamp] do
      {:noreply, socket |> set_assigns(event)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info(:get_torques, socket) do
    %{recording: recording, torques: torques} = GearRatios.get_torques()
    Process.send_after(self(), :get_torques, 1000)

    {
      :noreply,
      socket
      |> assign(torque_plot: torque_plot(torques))
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

  @impl true
  def handle_event(
        "validate_gearbox",
        %{"gearbox" => params},
        %{assigns: %{gearbox: gearbox}} = socket
      ) do
    changeset =
      gearbox
      |> Gearbox.changeset(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, gearbox_changeset: changeset)}
  end

  @impl true
  def handle_event(
        "save_gearbox",
        %{"gearbox" => params},
        %{assigns: %{gearbox: gearbox}} = socket
      ) do
    changeset =
      gearbox
      |> Gearbox.changeset(params)

    if changeset.valid? do
      {:ok, gearbox} = Ecto.Changeset.apply_action(changeset, :update)
      GearRatios.set_gearbox(gearbox)

      {
        :noreply,
        socket
        |> assign(gearbox: gearbox)
        |> assign_gearbox_changeset()
      }
    else
      {:noreply, socket |> assign(gearbox_changeset: changeset)}
    end
  end

  @impl true
  def handle_event(
        "validate_tires",
        %{"tires" => tires_params},
        %{assigns: %{tires: tires}} = socket
      ) do
    changeset =
      tires
      |> Tires.changeset(tires_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, tires_changeset: changeset)}
  end

  @impl true
  def handle_event(
        "save_tires",
        %{"tires" => tires_params},
        %{assigns: %{tires: tires}} = socket
      ) do
    changeset =
      tires
      |> Tires.changeset(tires_params)

    if changeset.valid? do
      {:ok, new_tires} = Ecto.Changeset.apply_action(changeset, :update)
      GearRatios.set_tire_size(new_tires)

      {
        :noreply,
        socket
        |> assign(tires: new_tires)
        |> assign_tires_changeset()
      }
    else
      {
        :noreply,
        socket
        |> assign(tires_changeset: changeset)
      }
    end
  end

  def handle_event("start_recording", data, socket) do
    GearRatios.start_recording()
    {:noreply, socket}
  end

  def handle_event("stop_recording", data, socket) do
    GearRatios.stop_recording()
    {:noreply, socket}
  end

  def handle_event("clear_recording", data, socket) do
    GearRatios.clear_recording()
    {:noreply, socket}
  end

  def handle_event("dyno_demo", data, socket) do
    ReadFile.start_link()
    {:noreply, socket}
  end

  def handle_event("get_wheel_forces", data, socket) do
    forces = GearRatios.get_wheel_forces()

    {
      :noreply,
      socket
      |> assign(force_plot: force_plot(forces))
    }
  end

  def handle_event("get_shift_points", data, socket) do
    shift_points = GearRatios.get_shift_points()

    {
      :noreply,
      socket
      |> assign(shift_points: shift_points)
    }
  end
end
