defmodule Rmc.ScreenDispatcher do
  @moduledoc """
    Sends parsed packets to screen agents
  """

  use GenServer
  require Logger

  def start_link() do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(_state) do
    Logger.info("Started ScreenDispatcher")
    {:ok, _session_pid} = Rmc.Screens.Session.start_link()
    {:ok, _} = Rmc.Screens.Timing.start_link()

    {:ok, :nil}
  end

  def handle_cast({:dispatch, %Rmc.FOne2018.Telemetries{} = parsed}, state) do
    GenServer.cast(:serial, {:put, parsed})
    {:noreply, state}
  end
  def handle_cast({:dispatch, %Rmc.FOne2018.Session{} = parsed}, state) do
    {should_broadcast, new_state} = Rmc.Screens.Session.put(parsed)
    if should_broadcast do
      RmcWeb.Endpoint.broadcast!("telemetry:session", "update", new_state)
    end
    {:noreply, state}
  end
  def handle_cast({:dispatch, %Rmc.FOne2018.Participants{} = parsed}, state) do
    {should_broadcast, new_state} = Rmc.Screens.Timing.put(parsed)
    if should_broadcast do
      RmcWeb.Endpoint.broadcast!("telemetry:timing", "update", new_state)
    end
    {:noreply, state}
  end
  def handle_cast(_, state), do: {:noreply, state}

  def dispatch(pid, parsed), do: GenServer.cast(pid, {:dispatch, parsed})
end