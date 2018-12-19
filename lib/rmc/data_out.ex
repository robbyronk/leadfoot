defmodule Rmc.DataOut do
  @moduledoc """
  Broadcasts data when all of the data for one tick is in.
  """
  use GenStage

  def start_link(producer) do
    GenStage.start_link(__MODULE__, producer, name: __MODULE__)
  end

  def init(producer) do
    {:consumer, :nil, subscribe_to: [producer]}
  end

  def handle_events(events, _from, old_session_time) do
    # todo events could be more than one race state
    [event] = events
    session_time = get_session_time(event)

    if session_time != old_session_time do
      broadcast(event)
    end
    {:noreply, [], session_time}
  end

  defp get_session_time(%{packet_header: %{session_time: time}}), do: time
  defp get_session_time(_), do: :nil

  def broadcast(event) do
    RmcWeb.Endpoint.broadcast!("telemetry:session", "update", RaceState.get_session())
    RmcWeb.Endpoint.broadcast!("telemetry:timing", "update", %{timing: RaceState.get_timing()})
  end
end
