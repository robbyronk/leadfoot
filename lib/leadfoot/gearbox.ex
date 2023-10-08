defmodule Leadfoot.Gearbox do
  @moduledoc """
  This module has functions to tune the gearbox.
  """

  alias Leadfoot.CarSettings.Gearbox
  alias Leadfoot.CarSettings.Tires

  @doc """
  Calculates the speed of the car in kph

      iex> Float.round(Leadfoot.Gearbox.get_speed(4.0, 1.0, 5000, 0.6), 2)
      141.37

      iex> Float.round(Leadfoot.Gearbox.get_speed(4.0, 2.0, 5000, 0.6), 2)
      70.69
  """
  def get_speed(final, gear, engine_rpm, wheel_diameter) do
    wheel_rpm = engine_rpm / (final * gear)
    wheel_rpm * 60 * :math.pi() * wheel_diameter / 1000
  end

  @doc """
  Calculates the force a single wheel is putting to the ground.

      iex> Float.round(Leadfoot.Gearbox.get_wheel_force(4.0, 1.0, 200, 2, 0.55), 2)
      1454.55

      iex> Float.round(Leadfoot.Gearbox.get_wheel_force(4.0, 1.0, 200, 4, 0.55), 2)
      727.27
  """
  def get_wheel_force(final, gear, engine_torque, total_drive_wheels, wheel_diameter) do
    wheel_torque = final * gear * engine_torque / total_drive_wheels
    wheel_torque * 2 / wheel_diameter
  end

  def calculate_forces(gearbox, tires, torques, drive_wheels) do
    wheel_diameter = Tires.get_tire_height(tires)

    gears = gearbox |> Gearbox.get_gears() |> Enum.with_index()

    for {rpm, torque} <- torques, {gear_ratio, gear_index} <- gears do
      {
        gear_index + 1,
        rpm,
        get_speed(gearbox.final, gear_ratio, rpm, wheel_diameter),
        get_wheel_force(gearbox.final, gear_ratio, torque, drive_wheels, wheel_diameter)
      }
    end
  end

  @doc """
  Given a list of force tuples, return only the highest forces for a given speed.

  Put another way, filter for the optimal gear at a given speed.
  """
  def get_optimal_forces([]), do: []

  def get_optimal_forces(forces) do
    forces
    |> Enum.group_by(&gear_elem/1)
    |> Map.new(fn {gear, forces} -> {gear, forces |> Enum.sort_by(&speed_elem/1) |> Enum.reverse()} end)
    |> optimal_forces_by_gear()
    |> Enum.sort_by(&speed_elem/1)
  end

  def optimal_forces_by_gear(forces) when is_map(forces) do
    forces
    |> Map.keys()
    |> Enum.sort()
    |> Enum.reverse()
    |> Enum.map(fn gear -> forces[gear] end)
    |> optimal_forces_by_gear()
  end

  def optimal_forces_by_gear([top_gear, down_gear | rest_gears]) do
    {top_gear_forces, down_gear} = rev_acc_optimal_forces(top_gear, down_gear)

    top_gear_forces ++ optimal_forces_by_gear([down_gear | rest_gears])
  end

  def optimal_forces_by_gear([first_gear]), do: Enum.reverse(first_gear)

  @doc """
  This function accumulates the optimal forces from the top most gear down.

  The forces given must be sorted in descending speed order.

  Returns a tuple {optimal_top_gear_forces, optimal_down_gear_forces}.

  The optimal_top_gear_forces are in ascending speed order.

  The optimal_down_gear_forces are in descending speed order, so they can be fed into the next call.

  If this ends up being inefficient, another possible option is checking the intersection of line segments
  like in https://stackoverflow.com/a/9997374

  todo: this blows up sometimes, possibly when gears are identical?
  """
  def rev_acc_optimal_forces([t | top_gear_forces], [d | down_gear_forces], acc \\ []) do
    {_, _, top_speed, top_force} = t
    {_, _, down_speed, down_force} = d

    cond do
      down_speed >= top_speed and down_force >= top_force ->
        {acc, [d | down_gear_forces]}

      down_speed >= top_speed ->
        rev_acc_optimal_forces([t | top_gear_forces], down_gear_forces, acc)

      length(top_gear_forces) == 0 ->
        {acc, [d | down_gear_forces]}

      true ->
        rev_acc_optimal_forces(top_gear_forces, [d | down_gear_forces], [t | acc])
    end
  end

  def get_shift_points(optimal_forces) do
    optimal_forces
    |> Enum.chunk_by(&gear_elem/1)
    |> Enum.map(&List.last/1)
  end

  defp gear_elem({gear, _, _, _}), do: gear

  defp speed_elem({_, _, speed, _}), do: speed

  def get_max_power(forces) do
    forces
    |> Enum.map(fn {_, _, speed, force} -> speed * force end)
    |> Enum.max()
  end

  def calculate_loss({gear, rpm, speed, force}, max_power) do
    {gear, rpm, speed, force, force - max_power / speed}
  end

  def calculate_losses([]), do: []

  def calculate_losses(optimal_forces) do
    max_power = get_max_power(optimal_forces)

    Enum.map(optimal_forces, &calculate_loss(&1, max_power))
  end
end
