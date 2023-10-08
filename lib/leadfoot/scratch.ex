defmodule Leadfoot.Scratch do
  @moduledoc false
  alias Leadfoot.Gearbox

  @total_gears 7
  @final 4.14
  @first_gear_ratio 3.8
  @top_gear_ratio 0.85
  @top_speed 371
  @tires %Leadfoot.CarSettings.Tires{
    width: 355,
    ratio: 25,
    size: 20
  }

  def write_chart_to_file(data, filename) do
    {:safe, svg} =
      data
      |> Contex.Dataset.new()
      |> Contex.Plot.new(Contex.PointPlot, 600, 400)
      |> Contex.Plot.to_svg()

    File.write(filename, svg |> List.flatten() |> Enum.join())
  end

  def get_torques do
    %{torques: torques} = Leadfoot.GearRatios.get_torques()
    torques
  end

  def get_random_gearbox do
    gearbox = %Leadfoot.CarSettings.Gearbox{
      final: @final,
      gear1: @first_gear_ratio
    }

    min_random_gear = @top_gear_ratio + 0.05
    max_random_gear = @first_gear_ratio * 0.85

    for_result =
      for _ <- 1..(@total_gears - 2) do
        Float.round(min_random_gear + :rand.uniform() * (max_random_gear - min_random_gear), 2)
      end

    random_gears =
      for_result
      |> List.insert_at(0, @top_gear_ratio)
      |> Enum.sort()
      |> Enum.reverse()

    Leadfoot.CarSettings.Gearbox.fill_gears(gearbox, random_gears)
  end

  def try_random_gearbox(torques) do
    gearbox = get_random_gearbox()

    drive_wheels = 4

    forces = Gearbox.calculate_forces(gearbox, @tires, torques, drive_wheels)
    optimal_forces = Gearbox.get_optimal_forces(forces)
    transmission_losses = Gearbox.calculate_losses(optimal_forces)

    total_loss =
      transmission_losses
      |> Enum.drop_while(fn {_, _, _, _, loss} -> loss > 5 end)
      |> Enum.take_while(fn {_, _, speed, _, _} -> speed < @top_speed end)
      |> Enum.map(fn {_, _, _, _, loss} -> loss end)
      |> Enum.sum()

    {gearbox, total_loss}
  end

  def find_nice_gearbox(tries \\ 10_000) do
    torques = get_torques()

    {best_gearbox, best_loss} =
      1..tries
      |> Enum.map(fn _ -> Task.async(fn -> try_random_gearbox(torques) end) end)
      |> Enum.map(&Task.await/1)
      |> Enum.max_by(fn {_, loss} -> loss end)

    IO.inspect(best_gearbox)
    IO.inspect(best_loss)

    drive_wheels = 4

    forces = Gearbox.calculate_forces(best_gearbox, @tires, torques, drive_wheels)
    optimal_forces = Gearbox.get_optimal_forces(forces)
    shift_points = Gearbox.get_shift_points(optimal_forces)
    IO.inspect(shift_points)
    :ok
  end

  def ideal_gearbox do
    #    %Leadfoot.CarSettings.Gearbox{
    #      final: 3.85,
    #      gear1: 4.14,
    #      gear2: 3.11,
    #      gear3: 2.39,
    #      gear4: 1.82,
    #      gear5: 1.33,
    #      gear6: 0.91,
    #    }
    %Leadfoot.CarSettings.Gearbox{
      final: 3.11,
      gear1: 3.42,
      gear10: nil,
      gear2: 2.7,
      gear3: 2.17,
      gear4: 1.7,
      gear5: 1.32,
      gear6: 1.07,
      gear7: 0.85,
      gear8: nil,
      gear9: nil
    }
  end

  def chart_ideal_losses(torques) do
    gearbox = ideal_gearbox()

    drive_wheels = 4

    forces = Gearbox.calculate_forces(gearbox, @tires, torques, drive_wheels)
    optimal_forces = Gearbox.get_optimal_forces(forces)
    transmission_losses = Gearbox.calculate_losses(optimal_forces)

    transmission_losses
    |> Enum.map(fn {_, _, speed, _, loss} -> {speed, loss} end)
    |> Enum.drop_while(fn {_, loss} -> loss > 5 end)
    |> write_chart_to_file("ideal-transmission-losses.svg")
  end

  def ideal_gearbox_shift_points(torques) do
    gearbox = ideal_gearbox()

    drive_wheels = 4

    forces = Gearbox.calculate_forces(gearbox, @tires, torques, drive_wheels)
    optimal_forces = Gearbox.get_optimal_forces(forces)
    Gearbox.get_shift_points(optimal_forces)
  end
end
