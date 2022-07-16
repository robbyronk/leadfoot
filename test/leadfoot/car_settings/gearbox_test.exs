defmodule Leadfoot.CarSettings.GearboxTest do
  use ExUnit.Case

  alias Leadfoot.CarSettings.Gearbox

  @moduletag :capture_log

  doctest Gearbox

  test "module exists" do
    assert is_list(Gearbox.module_info())
  end

  test "fill gears" do
    gearbox = %Gearbox{final: 3.3}

    actual = Gearbox.fill_gears(gearbox, [5.5, 4.4, 3.3, 2.2, 1.1])

    expected = %Gearbox{
      final: 3.3,
      gear1: 5.5,
      gear2: 4.4,
      gear3: 3.3,
      gear4: 2.2,
      gear5: 1.1
    }

    assert actual == expected
  end
end
