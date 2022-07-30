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
  import LeadfootWeb.UI.Buttons

  @initial_assigns %{
    event: nil,
    recording: false,
    torque_plot: "",
    force_plot: "",
    rpm_plot: "",
    loss_plot: "",
    torques: [],
    gearbox: %Gearbox{},
    gearbox_changeset: nil,
    tires: %Tires{},
    tires_changeset: nil,
    torques: [],
    shift_points: []
  }

  @impl true
  def mount(_params, session, socket) do
    tires = GearRatios.get_tires()
    gearbox = GearRatios.get_gearbox()

    {
      :ok,
      socket
      |> assign(@initial_assigns)
      |> assign(tires: tires, gearbox: gearbox)
      |> assign_tires_changeset()
      |> assign_gearbox_changeset()
      |> assign_torques()
      |> assign_updated_outputs()
    }
  end

  def assign_updated_outputs(socket) do
    socket
    |> assign_forces()
    |> assign_shift_points()
    |> assign_torque_chart()
    |> assign_force_plot()
    |> assign_rpm_speed_chart()
    |> assign_loss_plot()
  end

  def assign_tires_changeset(%{assigns: %{tires: tires}} = socket) do
    assign(socket, tires_changeset: Tires.changeset(tires, %{}))
  end

  def assign_gearbox_changeset(%{assigns: %{gearbox: gearbox}} = socket) do
    assign(socket, gearbox_changeset: Gearbox.changeset(gearbox, %{}))
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
        |> assign_updated_outputs()
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
        |> assign_updated_outputs()
      }
    else
      {
        :noreply,
        socket
        |> assign(tires_changeset: changeset)
      }
    end
  end

  def assign_torques(%{assigns: %{torques: []}} = socket) do
    torques =
      File.read!("test/fixtures/22b-torques")
      |> :erlang.binary_to_term()
      |> Map.get(:torques)

    assign(socket, torques: torques)
  end

  def assign_torques(socket), do: socket

  def assign_forces(socket) do
    forces =
      Leadfoot.Gearbox.calculate_forces(
        socket.assigns.gearbox,
        socket.assigns.tires,
        socket.assigns.torques,
        4
      )

    assign(socket, forces: forces, optimal_forces: Leadfoot.Gearbox.get_optimal_forces(forces))
  end

  def assign_loss_plot(socket) do
    transmission_losses =
      Leadfoot.Gearbox.calculate_losses(socket.assigns.optimal_forces)
      |> Enum.drop_while(fn {_, _, _, _, loss} -> loss > 5 end)
      |> Enum.take_while(fn {_, _, speed, _, _} -> speed < 250 end)

    data =
      for {_, _, speed, _, loss} <- transmission_losses do
        {speed, loss}
      end

    assign(socket, loss_plot: force_plot(data), losses: transmission_losses)
  end

  def assign_shift_points(socket) do
    assign(socket, shift_points: Leadfoot.Gearbox.get_shift_points(socket.assigns.optimal_forces))
  end

  def assign_torque_chart(socket) do
    assign(socket, torque_plot: torque_plot(socket.assigns.torques))
  end

  def assign_force_plot(socket) do
    data =
      for {_, _, speed, force} <- socket.assigns.forces do
        {speed, force}
      end

    assign(socket, force_plot: force_plot(data))
  end

  def assign_rpm_speed_chart(socket) do
    data =
      for {_, rpm, speed, _} <- socket.assigns.optimal_forces do
        {speed, rpm}
      end

    assign(socket, rpm_plot: force_plot(data))
  end
end
