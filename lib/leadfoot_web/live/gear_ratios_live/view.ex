defmodule LeadfootWeb.GearRatiosLive.View do
  @moduledoc false
  use LeadfootWeb, :live_view
  alias Phoenix.PubSub
  alias Leadfoot.GearRatios
  alias Leadfoot.ReadFile
  alias Leadfoot.CarSettings.Tires
  import Leadfoot.SampleEvent
  import Leadfoot.Translation

  @initial_assigns %{
    event: nil,
    recording: false,
    torque_plot: "",
    force_plot: "",
    torques: [],
    final: 3.85,
    gear1: 4.14,
    gear2: 2.67,
    gear3: 1.82,
    gear4: 1.33,
    gear5: 1.0,
    gear6: 0.8,
    gear7: 0.0,
    gear8: 0.0,
    gear9: 0.0,
    gear10: 0.0,
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
    }
  end

  def assign_tires_changeset(%{assigns: %{tires: tires}} = socket) do
    assign(socket, tires_changeset: Tires.changeset(tires, %{}))
  end

  def handle_info({:event, event}, socket) do
    {
      :noreply,
      socket
      |> set_assigns(event)
    }
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
        "save_gears",
        %{
          "final" => final,
          "gear1" => gear1,
          "gear2" => gear2,
          "gear3" => gear3,
          "gear4" => gear4,
          "gear5" => gear5,
          "gear6" => gear6,
          "gear7" => gear7,
          "gear8" => gear8,
          "gear9" => gear9,
          "gear10" => gear10
        },
        socket
      ) do
    {final, _} = Float.parse(final)
    {gear1, _} = Float.parse(gear1)
    {gear2, _} = Float.parse(gear2)
    {gear3, _} = Float.parse(gear3)
    {gear4, _} = Float.parse(gear4)
    {gear5, _} = Float.parse(gear5)
    {gear6, _} = Float.parse(gear6)
    {gear7, _} = Float.parse(gear7)
    {gear8, _} = Float.parse(gear8)
    {gear9, _} = Float.parse(gear9)
    {gear10, _} = Float.parse(gear10)

    gears = [gear1, gear2, gear3, gear4, gear5, gear6, gear7, gear8, gear9, gear10]
    gears = Enum.take_while(gears, fn g -> g > 0.0 end)
    :ok = GearRatios.set_gears(final, gears)

    {
      :noreply,
      socket
      |> assign(
        final: final,
        gear1: gear1,
        gear2: gear2,
        gear3: gear3,
        gear4: gear4,
        gear5: gear5,
        gear6: gear6,
        gear7: gear7,
        gear8: gear8,
        gear9: gear9,
        gear10: gear10
      )
    }
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
