defmodule Rmc.RaceState do
  @moduledoc """
  This agent holds state about the race.

  The state is a map.

  The :racers key holds all the data about racers: (TODO)
  - motion
  - setup
  - status
  - lap
  - participant
  - telemetry
  """
  use Agent
  @name __MODULE__

  def start_link(opts \\ []) do
    opts = Keyword.put_new(opts, :name, @name)
    Agent.start_link(fn -> %{} end, opts)
  end

  def get(name \\ @name) do
    Agent.get(name, fn x -> x end)
  end

  def get_session_time(name \\ @name) do
    Agent.get(name, fn
      %{packet_header: %{session_time: time}} -> time
      _ -> nil
    end)
  end

  @doc """
  merge_racer calculates the sector three time when a new lap starts and merges new data into the existing map
  """
  def merge_racer(%{current_lap_num: old_lap} = old, %{current_lap_num: now_lap} = now)
      when old_lap != now_lap do
    sector_three_time =
      Map.get(now, :last_lap_time, 0) -
        (Map.get(old, :sector_one_time, 0) + Map.get(old, :sector_one_time, 0))

    old
    |> Map.merge(now)
    |> Map.put(:sector_three_time, sector_three_time)
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

  def put(u, name \\ @name), do: Agent.update(name, &merge_state(&1, Map.to_list(u)))

  def get_session(name \\ @name) do
    fields = [
      :total_laps,
      :track_temperature,
      :air_temperature,
      :weather,
      :session_type,
      :track_id
    ]

    Agent.get(name, &Map.take(&1, fields))
  end

  def get_timing(name \\ @name) do
    fields = [
      :car_position,
      :tyre_compound,
      :best_lap_time,
      :last_lap_time,
      :sector_one_time,
      :sector_two_time,
      :sector_three_time,
      :name,
      :race_number
    ]

    Agent.get(name, fn state ->
      state
      |> Map.get(:racers, [])
      |> Enum.map(&Map.take(&1, fields))
    end)
  end
end
