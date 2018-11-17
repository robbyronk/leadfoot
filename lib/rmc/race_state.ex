defmodule Rmc.RaceState do
  use Agent

  def start_link(initial_state \\ %{}) do
    Agent.start_link(fn -> initial_state end, name: :race_state)
  end

  def get() do
    Agent.get(:race_state, fn x -> x end)
  end

  def put(%{} = u) do
    Agent.update(:race_state, &Map.merge(&1, u))
  end
end