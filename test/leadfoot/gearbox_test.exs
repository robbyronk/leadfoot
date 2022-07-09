defmodule Leadfoot.GearboxTest do
  use ExUnit.Case

  alias Leadfoot.Gearbox

  @moduletag :capture_log

  doctest Gearbox

  test "module exists" do
    assert is_list(Gearbox.module_info())
  end

  test "calculate everything for 22b" do
    %{torques: torques} = File.read!("test/fixtures/22b-torques") |> :erlang.binary_to_term

    gearbox = %Leadfoot.CarSettings.Gearbox{
      final: 3.85,
      gear1: 4.14,
      gear2: 2.67,
      gear3: 1.82,
      gear4: 1.33,
      gear5: 1.0,
      gear6: 0.8
    }

    tires = %Leadfoot.CarSettings.Tires{
      width: 235, ratio: 40, size: 17
    }
    drive_wheels = 4

    forces = Gearbox.calculate_forces(gearbox, tires, torques, drive_wheels)
    optimal_forces = Gearbox.get_optimal_forces(forces)

    assert length(forces) > 2700
    assert length(optimal_forces) > 1100
  end

  test "accumulate forces when the down gear is best over all speeds" do
    first_gear = [
      {1, 5000, 51, 110},
      {1, 4000, 41, 120},
      {1, 3000, 31, 130},
      {1, 2000, 21, 120},
      {1, 1000, 11, 100}
    ]

    second_gear = [
      {2, 5000, 70, 11},
      {2, 4000, 60, 12},
      {2, 3000, 50, 13},
      {2, 2000, 40, 12},
      {2, 1000, 30, 10}
    ]

    {optimal_second_gear, optimal_first_gear} =
      Gearbox.rev_acc_optimal_forces(second_gear, first_gear)

    assert optimal_first_gear == first_gear

    expected_second_gear = [
      {2, 4000, 60, 12},
      {2, 5000, 70, 11}
    ]

    assert optimal_second_gear == expected_second_gear
  end

  test "accumulate forces when the top gear is best in some speeds" do
    first_gear = [
      {1, 5000, 51, 11},
      {1, 4000, 41, 120},
      {1, 3000, 31, 130},
      {1, 2000, 21, 120},
      {1, 1000, 11, 100}
    ]

    second_gear = [
      {2, 5000, 70, 115},
      {2, 4000, 60, 125},
      {2, 3000, 50, 135},
      {2, 2000, 40, 115},
      {2, 1000, 30, 100}
    ]

    {optimal_second_gear, optimal_first_gear} =
      Gearbox.rev_acc_optimal_forces(second_gear, first_gear)

    expected_first_gear = [
      {1, 4000, 41, 120},
      {1, 3000, 31, 130},
      {1, 2000, 21, 120},
      {1, 1000, 11, 100}
    ]

    assert optimal_first_gear == expected_first_gear

    expected_second_gear = [
      {2, 3000, 50, 135},
      {2, 4000, 60, 125},
      {2, 5000, 70, 115}
    ]

    assert optimal_second_gear == expected_second_gear
  end

  test "get optimal forces for two gears" do
    forces = [
      {1, 5000, 51, 11},
      {1, 4000, 41, 120},
      {1, 3000, 31, 130},
      {1, 2000, 21, 120},
      {1, 1000, 11, 100},
      {2, 5000, 70, 115},
      {2, 4000, 60, 125},
      {2, 3000, 50, 135},
      {2, 2000, 40, 115},
      {2, 1000, 30, 100}
    ]

    optimal_forces = Gearbox.get_optimal_forces(forces)

    expected = [
      {1, 1000, 11, 100},
      {1, 2000, 21, 120},
      {1, 3000, 31, 130},
      {1, 4000, 41, 120},
      {2, 3000, 50, 135},
      {2, 4000, 60, 125},
      {2, 5000, 70, 115}
    ]

    assert optimal_forces == expected
  end

  test "get optimal forces for three gears" do
    forces = [
      {1, 5000, 51, 11},
      {1, 4000, 41, 120},
      {1, 3000, 31, 130},
      {1, 2000, 21, 120},
      {1, 1000, 11, 100},
      {2, 5000, 70, 115},
      {2, 4000, 60, 125},
      {2, 3000, 50, 135},
      {2, 2000, 40, 115},
      {2, 1000, 30, 100},
      {3, 5000, 100, 115},
      {3, 4000, 90, 125},
      {3, 3000, 80, 135},
      {3, 2000, 69, 116},
      {3, 1000, 60, 100}
    ]

    optimal_forces = Gearbox.get_optimal_forces(forces)

    expected = [
      {1, 1000, 11, 100},
      {1, 2000, 21, 120},
      {1, 3000, 31, 130},
      {1, 4000, 41, 120},
      {2, 3000, 50, 135},
      {2, 4000, 60, 125},
      {3, 2000, 69, 116},
      {3, 3000, 80, 135},
      {3, 4000, 90, 125},
      {3, 5000, 100, 115}
    ]

    assert optimal_forces == expected
  end
end
