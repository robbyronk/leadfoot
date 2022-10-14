defmodule Leadfoot.SuspensionTest do
  use ExUnit.Case

  alias Leadfoot.Suspension

  @moduletag :capture_log

  doctest Suspension

  test "module exists" do
    assert is_list(Suspension.module_info())
  end
end
