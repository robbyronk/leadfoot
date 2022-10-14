defmodule Leadfoot.Suspension.CalculatorTest do
  use ExUnit.Case

  alias Leadfoot.Suspension.Calculator

  @moduletag :capture_log

  doctest Calculator

  test "module exists" do
    assert is_list(Calculator.module_info())
  end

  test "calculate frequencies" do
    calc = %Calculator{
      front_downforce: 100.0,
      rear_downforce: 100.0,
      front_spring_rate: 100.0,
      rear_spring_rate: 100.0,
      mass: 1000,
      front_distribution: 50
    }

    {
      front,
      rear,
      front_with_downforce,
      rear_with_downforce
    } = Calculator.get_frequencies(calc)

    assert Float.round(front, 2) == 3.18
    assert Float.round(rear, 2) == 3.18
    assert Float.round(front_with_downforce, 2) == 2.91
    assert Float.round(rear_with_downforce, 2) == 2.91
  end
end
