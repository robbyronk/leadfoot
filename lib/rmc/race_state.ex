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

  @doc """
  This function merges lists of maps
  """
  def merge_fn(_key, old, now)
      when is_list(old) and is_list(now) and length(old) == length(now) do
    Enum.map(Enum.zip(old, now), fn {a, b} -> Map.merge(a, b) end)
  end

  def merge_fn(_key, _old, now), do: now

  def put(u, name \\ @name), do: Agent.update(name, fn x -> Map.merge(x, u, &merge_fn/3) end)

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

  def transpose(rows) do
    rows
    |> List.zip()
    |> Enum.map(&Tuple.to_list/1)
  end

  def get_timing(name \\ @name) do
    fields = [:participants, :laps, :statuses]

    name
    |> Agent.get(fn state ->
      state
      |> Map.take(fields)
      |> Map.values()
      |> transpose()
      |> Enum.map(fn x -> Enum.reduce(x, &Map.merge/2) end)
    end)
    |> Enum.map(&Map.from_struct/1)
  end
end
