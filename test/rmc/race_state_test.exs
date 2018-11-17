defmodule RaceStateTest do
  use ExUnit.Case

  alias Rmc.RaceState

  @moduletag :capture_log

  doctest RaceState

  test "module exists" do
    assert is_list(RaceState.module_info())
  end

  test "stores basic values" do
    {:ok, _pid} = RaceState.start_link()
    assert RaceState.get() == %{}

    RaceState.put(%{session_id: 1})
    assert RaceState.get() == %{session_id: 1}
  end

  test "overwrites nested maps" do
    {:ok, _pid} = RaceState.start_link(%{header: %{session_id: 1}, weather: "sunny"})
    assert RaceState.get() == %{header: %{session_id: 1}, weather: "sunny"}

    RaceState.put(%{header: %{session_id: 2}})
    assert RaceState.get() == %{header: %{session_id: 2}, weather: "sunny"}
  end
end
