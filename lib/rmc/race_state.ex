defmodule Rmc.RaceState do
  use Agent
  @name __MODULE__

  def start_link(opts \\ []) do
    opts = Keyword.put_new(opts, :name, @name)
    Agent.start_link(fn -> %{} end, opts)
  end

  def get(name \\ @name) do
    Agent.get(name, fn x -> x end)
  end

  def put(u), do: Agent.update(@name, &Map.merge(&1, u))
  def put(name, u), do: Agent.update(name, &Map.merge(&1, u))

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
