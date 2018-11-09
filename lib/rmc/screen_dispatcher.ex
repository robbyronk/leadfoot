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

    {:ok, :nil}
  end

  def handle_cast({:dispatch, %Rmc.FOne2018.Session{} = parsed}, state) do
    IO.inspect(parsed)
    Rmc.Screens.Session.put(parsed)
    {:noreply, state}
  end
  def handle_cast(_, state), do: {:noreply, state}

  def dispatch(pid, parsed), do: GenServer.cast(pid, {:dispatch, parsed})
end