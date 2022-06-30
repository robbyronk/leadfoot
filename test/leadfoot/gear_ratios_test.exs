defmodule Leadfoot.GearRatiosTest do
  use ExUnit.Case

  alias Leadfoot.GearRatios

  @moduletag :capture_log

  doctest GearRatios

  test "module exists" do
    assert is_list(GearRatios.module_info())
  end
end
