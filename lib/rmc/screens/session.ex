defmodule Rmc.Screens.Session do
  use Agent
  @moduledoc """
  The session screen has the following information on it:
  - Track Name (id from session packet)
  - Session Type (id from session packet)
  - Number of laps (from session packet)
  - Weather (id from session packet)
  - Track Temp (from session packet)
  - Air Temp (from session packet)
  """


  @doc """
  Starts a new session screen.
  """
  def start_link() do
    Agent.start_link(fn -> %{} end, name: :session_screen)
  end

  @doc """
  Gets the Agent state.
  """
  def get() do
    Agent.get(:session_screen, fn x -> x end)
  end

  @doc """
  Puts the `value` for the given `key` in the `bucket`.
  """
  def put(%Rmc.FOne2018.Session{} = session) do
    for_screen = Map.take(session, [:total_laps, :track_temperature, :air_temperature])
    Agent.update(
      :session_screen,
      fn state ->
        new_state = Map.merge(state, for_screen)
        if Map.equal?(state, new_state) do
          state
        else
          RmcWeb.Endpoint.broadcast!("telemetry:session", "update", new_state)
          new_state
        end
      end
    )
  end
end