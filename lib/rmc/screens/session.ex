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
  Gets the screen state.
  """
  def get() do
    Agent.get(:session_screen, fn x -> x end)
  end

  defp update(update) do
    fn state ->
      new_state = Map.merge(state, update)
      {{!Map.equal?(state, new_state), new_state}, new_state}
    end
  end

  @doc """
  Updates the screen state and sends a channel broadcast if there was a change.
  """
  def put(%Rmc.FOne2018.Session{} = session) do
    for_screen =
      Map.take(session, [
        :total_laps,
        :track_temperature,
        :air_temperature,
        :weather,
        :session_type,
        :track_id
      ])

    Agent.get_and_update(:session_screen, update(for_screen))
  end
end
