defmodule RaceStateTest do
  use ExUnit.Case

  alias Rmc.RaceState
  alias Rmc.FOne2018

  @moduletag :capture_log

  doctest RaceState

  setup do
    RaceState.start_link(name: __MODULE__)
    :ok
  end

  test "module exists" do
    assert is_list(RaceState.module_info())
  end

  test "stores basic values" do
    assert RaceState.get(__MODULE__) == %{}

    RaceState.put(%{session_id: 1}, __MODULE__)
    assert RaceState.get(__MODULE__) == %{session_id: 1}
  end

  test "overwrites nested maps" do
    RaceState.put(%{header: %{session_id: 1}, weather: "sunny"}, __MODULE__)
    assert RaceState.get(__MODULE__) == %{header: %{session_id: 1}, weather: "sunny"}

    RaceState.put(%{header: %{session_id: 2}}, __MODULE__)
    assert RaceState.get(__MODULE__) == %{header: %{session_id: 2}, weather: "sunny"}
  end

  test "merges two parsed packets" do
    RaceState.put(
      %FOne2018.Event{
        code: "SSTA",
        packet_header: %FOne2018.PacketHeader{session_uid: 4}
      },
      __MODULE__
    )

    %{code: code} = RaceState.get(__MODULE__)
    assert code == "SSTA"

    RaceState.put(
      %FOne2018.Session{
        total_laps: 3,
        packet_header: %FOne2018.PacketHeader{session_uid: 4}
      },
      __MODULE__
    )

    %{code: code, total_laps: total_laps} = RaceState.get(__MODULE__)
    assert code == "SSTA"
    assert total_laps == 3
  end

  test "get session data" do
    RaceState.put(
      %FOne2018.Event{
        code: "SSTA",
        packet_header: %FOne2018.PacketHeader{session_uid: 4}
      },
      __MODULE__
    )

    RaceState.put(
      %FOne2018.Session{
        total_laps: 3,
        packet_header: %FOne2018.PacketHeader{session_uid: 4}
      },
      __MODULE__
    )

    session = RaceState.get_session(__MODULE__)
    assert session[:total_laps] == 3
    assert Map.get(session, :code) == nil
  end

  test "get timing data" do
    RaceState.put(
      %FOne2018.Laps{
        laps: [%FOne2018.Lap{last_lap_time: 23.4}, %FOne2018.Lap{last_lap_time: 98.8}]
      },
      __MODULE__
    )

    RaceState.put(
      %FOne2018.Participants{
        participants: [
          %FOne2018.Participant{race_number: 1},
          %FOne2018.Participant{race_number: 2}
        ]
      },
      __MODULE__
    )

    [first, second] = RaceState.get_timing(__MODULE__)
    assert first.last_lap_time == 23.4
    assert second.race_number == 2
  end
end
