defmodule Leadfoot.LapTimesTest do
  use ExUnit.Case

  alias Leadfoot.LapTimes

  @moduletag :capture_log

  doctest LapTimes

  test "module exists" do
    assert is_list(LapTimes.module_info())
  end

  test "does not capture same lap time twice" do
    lap_time = %{
      lap: 1,
      time: 12.1
    }

    state = %{lap_times: []}

    state = LapTimes.capture_lap_time(lap_time, state)
    state = LapTimes.capture_lap_time(lap_time, state)

    assert length(state.lap_times) == 1
  end

  test "captures some lap times" do
    state = %{lap_times: []}

    state =
      LapTimes.capture_lap_time(
        %{
          lap: 1,
          time: 12.1
        },
        state
      )

    state =
      LapTimes.capture_lap_time(
        %{
          lap: 2,
          time: 11.1
        },
        state
      )

    state =
      LapTimes.capture_lap_time(
        %{
          lap: 3,
          time: 11.1
        },
        state
      )

    assert length(state.lap_times) == 3
  end
end
