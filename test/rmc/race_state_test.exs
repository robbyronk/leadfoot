defmodule RaceStateTest do
  use ExUnit.Case

  alias Rmc.RaceState
  alias Rmc.FOne2018

  @moduletag :capture_log
  @name __MODULE__

  doctest RaceState

  setup do
    RaceState.start_link(name: @name)
    :ok
  end

  test "module exists" do
    assert is_list(RaceState.module_info())
  end

  test "stores basic values" do
    assert RaceState.get(@name) == %{}

    RaceState.put(%{session_id: 1}, @name)
    assert RaceState.get(@name) == %{session_id: 1}
  end

  test "overwrites nested maps" do
    RaceState.put(
      %{
        header: %{
          session_id: 1
        },
        weather: "sunny"
      },
      @name
    )
    assert RaceState.get(@name) == %{
             header: %{
               session_id: 1
             },
             weather: "sunny"
           }

    RaceState.put(
      %{
        header: %{
          session_id: 2
        }
      },
      @name
    )
    assert RaceState.get(@name) == %{
             header: %{
               session_id: 2
             },
             weather: "sunny"
           }
  end

  test "merges two parsed packets" do
    RaceState.put(
      %FOne2018.Event{
        code: "SSTA",
        packet_header: %FOne2018.PacketHeader{
          session_uid: 4
        }
      },
      @name
    )

    %{code: code} = RaceState.get(@name)
    assert code == "SSTA"

    RaceState.put(
      %FOne2018.Session{
        total_laps: 3,
        packet_header: %FOne2018.PacketHeader{
          session_uid: 4
        }
      },
      @name
    )

    %{code: code, total_laps: total_laps} = RaceState.get(@name)
    assert code == "SSTA"
    assert total_laps == 3
  end

  test "get session data" do
    RaceState.put(
      %FOne2018.Event{
        code: "SSTA",
        packet_header: %FOne2018.PacketHeader{
          session_uid: 4
        }
      },
      @name
    )

    RaceState.put(
      %FOne2018.Session{
        total_laps: 3,
        packet_header: %FOne2018.PacketHeader{
          session_uid: 4
        }
      },
      @name
    )

    session = RaceState.get_session(@name)
    assert session[:total_laps] == 3
    assert Map.get(session, :code) == nil
  end

  test "get timing data" do
    RaceState.put(
      %FOne2018.Laps{
        laps: [%FOne2018.Lap{last_lap_time: 23.4}, %FOne2018.Lap{last_lap_time: 98.8}]
      },
      @name
    )

    RaceState.put(
      %FOne2018.Participants{
        participants: [
          %FOne2018.Participant{race_number: 1},
          %FOne2018.Participant{race_number: 2}
        ]
      },
      @name
    )

    [first, second] = RaceState.get_timing(@name)
    assert first.last_lap_time == 23.4
    assert second.race_number == 2
  end

  test "get sector 3 time" do
    RaceState.put(
      %FOne2018.Laps{
        laps: [
          %FOne2018.Lap{current_lap_num: 1, last_lap_time: 23.4, sector_one_time: 10.1, sector_two_time: 5.5},
        ]
      },
      @name
    )


    RaceState.put(
      %FOne2018.Laps{
        laps: [
          %FOne2018.Lap{current_lap_num: 2, last_lap_time: 19.9},
        ]
      },
      @name
    )

    [first] = RaceState.get_timing(@name)
    assert_in_delta(first.sector_three_time, 4.3, 0.1)
  end

  test "get all lap times" do
    RaceState.put(
      %FOne2018.Laps{
        laps: [
          %FOne2018.Lap{current_lap_num: 1, sector_one_time: 5.5, sector_two_time: 5.6},
        ]
      },
      @name
    )


    RaceState.put(
      %FOne2018.Laps{
        laps: [
          %FOne2018.Lap{current_lap_num: 2, last_lap_time: 19.9},
        ]
      },
      @name
    )

    [first] = RaceState.get_timing(@name)
    assert [{1, 19.9}] = first.laps
  end
end
