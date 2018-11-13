defmodule Rmc.Screens.Timing do
  use Agent
  @moduledoc """
  The timing screen has the following information on it:
    - position (lap packet)
    - car number (participant packet)
    - name (participant packet)
    - gap (will need to generate this)
    - interval (will need to generate this)
    - last lap time (lap packet)
    - last s1 (lap packet)
    - last s2 (lap packet)
    - last s3 (generated from last lap - (s1 + s2) when starting a new lap)
    - best lap time (lap packet)
    - tyre compound (car status packet)
    - (not shown) current lap (lap packet, used to create s3)
  """

  @doc """
  Starts a new timing screen.
  """
  def start_link() do
    Agent.start_link(fn -> %{} end, name: :timing_screen)
  end

  @doc """
  Gets the screen state.
  """
  def get() do
    Agent.get(:timing_screen, fn x -> x end)
  end

  defp update(update) do
    fn state ->
      new_state = Map.merge(state, update)
      {{!Map.equal?(state, new_state), new_state}, new_state}
    end
  end

  @doc """
  Updates the screen state and returns if the state has changed with the current state.
  """
  def put(%Rmc.FOne2018.Participants{participants: ps}) do
    p = Enum.map(ps, &Map.take(&1, [:name, :race_number]))
    Agent.get_and_update(:timing_screen, update(%{timing: p}))
  end
end