defmodule Leadfoot.Scratch do
  alias Leadfoot.Gearbox

  def write_chart_to_file(data, filename) do
    {:safe, svg} =
      data
      |> Contex.Dataset.new()
      |> Contex.Plot.new(Contex.PointPlot, 600, 400)
      |> Contex.Plot.to_svg()

    File.write(filename, List.flatten(svg) |> Enum.join())
  end

  def get_torques() do
    File.read!("test/fixtures/22b-torques")
    |> :erlang.binary_to_term()
    |> Map.get(:torques)
  end

  def get_random_gearbox() do
    gearbox = %Leadfoot.CarSettings.Gearbox{
      final: 3.85,
      gear1: 4.14
    }
    random_gears = for _ <- 1..5 do
                     Float.round(1.1 + :rand.uniform() * (4.1 - 1.1), 2)
                   end
                   |> List.insert_at(0, 1.0)
                   |> Enum.sort()
                   |> Enum.reverse()
    Leadfoot.CarSettings.Gearbox.fill_gears(gearbox, random_gears)
  end

  def try_random_gearbox(torques) do
    gearbox = get_random_gearbox()

    tires = %Leadfoot.CarSettings.Tires{
      width: 235,
      ratio: 40,
      size: 17
    }

    drive_wheels = 4

    forces = Gearbox.calculate_forces(gearbox, tires, torques, drive_wheels)
    optimal_forces = Gearbox.get_optimal_forces(forces)
    transmission_losses = Gearbox.calculate_losses(optimal_forces)

    total_loss = transmission_losses
    |> Enum.drop_while(fn {_, _, _, _, loss} -> loss > 5 end)
    |> Enum.take_while(fn {_, _, speed, _, _} -> speed < 250 end)
    |> Enum.map(fn {_, _, _, _, loss} -> loss end)
    |> Enum.sum()

    {gearbox, total_loss}
  end

  def find_nice_gearbox(tries \\ 10000) do
    torques = get_torques()

    {best_gearbox, best_loss} = 1..tries
    |> Enum.map(fn _ -> Task.async(fn -> try_random_gearbox(torques) end) end)
    |> Enum.map(&Task.await/1)
    |> Enum.min_by(fn {_, loss} -> loss end)

    IO.inspect(best_gearbox)
    IO.inspect(best_loss)

    tires = %Leadfoot.CarSettings.Tires{
      width: 235,
      ratio: 40,
      size: 17
    }

    drive_wheels = 4

    forces = Gearbox.calculate_forces(best_gearbox, tires, torques, drive_wheels)
    optimal_forces = Gearbox.get_optimal_forces(forces)
    shift_points = Gearbox.get_shift_points(optimal_forces)
    IO.inspect(shift_points)
    :ok
  end

  def ideal_gearbox() do
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
      final: 3.85,
      gear1: 4.14,
      gear10: nil,
      gear2: 3.5,
      gear3: 2.92,
      gear4: 2.28,
      gear5: 1.69,
      gear6: 1.24,
      gear7: 0.95,
      gear8: nil,
      gear9: nil
    }
  end

  def chart_ideal_losses(torques) do

    gearbox = ideal_gearbox()

    tires = %Leadfoot.CarSettings.Tires{
      width: 235,
      ratio: 40,
      size: 17
    }

    drive_wheels = 4

    forces = Gearbox.calculate_forces(gearbox, tires, torques, drive_wheels)
    optimal_forces = Gearbox.get_optimal_forces(forces)
    transmission_losses = Gearbox.calculate_losses(optimal_forces)

    transmission_losses
    |> Enum.map(fn {_, _, speed, _, loss} -> {speed, loss} end)
    |> Enum.drop_while(fn {_, loss} -> loss > 5 end)
    |> write_chart_to_file("ideal-transmission-losses.svg")
  end

  def ideal_gearbox_shift_points(torques) do
    gearbox = ideal_gearbox()

    tires = %Leadfoot.CarSettings.Tires{
      width: 235,
      ratio: 40,
      size: 17
    }

    drive_wheels = 4

    forces = Gearbox.calculate_forces(gearbox, tires, torques, drive_wheels)
    optimal_forces = Gearbox.get_optimal_forces(forces)
    Gearbox.get_shift_points(optimal_forces)
  end
end
