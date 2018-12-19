defmodule Rmc.RaceState do
  @moduledoc """
  This module contains functions that take in a Race State and a parsed packet and produce a new Race State.

  The state is a map.

  The :racers key holds all the data about racers:
  - motion
  - setup
  - status
  - lap
  - participant
  - telemetry
  """
  alias Rmc.FOne2018.Lap
  @name __MODULE__

  defp true_map_update(map, key, initial, func) do
    if Map.has_key?(map, key) do
      Map.update(map, key, initial, func)
    else
      Map.put(map, key, func.(initial))
    end
  end

  @doc """
  merge_racer calculates the sector three time when a new lap starts and merges new data into the existing map
  """
  def merge_racer(%{current_lap_num: old_lap} = old, %{current_lap_num: now_lap} = now)
      when old_lap != now_lap do
    sector_three_time =
      Map.get(now, :last_lap_time, 0) -
        (Map.get(old, :sector_one_time, 0) + Map.get(old, :sector_two_time, 0))

    old
    |> Map.merge(now)
    |> Map.put(:sector_three_time, sector_three_time)
    |> true_map_update(:laps, [], &List.insert_at(&1, 0, {old.current_lap_num, now.last_lap_time}))
  end

  # todo needs to have session time available here
  def merge_racer(old, %Lap{} = now) do
    old
    |> Map.merge(now)
    |> true_map_update(:track_time_locations, [], &List.insert_at(&1, 0, {now.current_lap_time, now.lap_distance}))
  end

  def merge_racer(old, now), do: Map.merge(old, now)

  @doc """
  merge_racers steps through each of the maps in the given list and runs merge_racer
  """
  def merge_racers([], now), do: now

  def merge_racers([old | rest_old], [now | rest_now]),
      do: [merge_racer(old, now) | merge_racers(rest_old, rest_now)]

  @doc """
  merge_state takes a state and a list of key value pairs to merge in

  Some key value pairs get diverted to be merged into the :racers key, which is a list of maps
  """
  def merge_state(state, parsed_packet) when is_map?(parsed_packet), do: merge_state(state, Map.to_list(parsed_packet))

  def merge_state(acc, []), do: acc

  def merge_state(acc, [{key, value} | rest])
      when key in [:laps, :participants, :motions, :car_setups, :statuses, :telemetries] do
    acc
    |> Map.put(:racers, merge_racers(Map.get(acc, :racers, []), value))
    |> merge_state(rest)
  end

  def merge_state(acc, [{key, value} | rest]) do
    acc
    |> Map.put(key, value)
    |> merge_state(rest)
  end

end
