defmodule Rmc.StateBroker do
  @moduledoc """
  State Broker starts file or udp, for replays or live viewing.

  It receives messages and updates Race State.

  If the session time has advanced, it broadcasts the update.
  """
  use GenServer
  require Logger
  alias Rmc.RaceState
  @name __MODULE__

  def start_link(opts \\ []) do
    opts = Keyword.put_new(opts, :name, @name)
    GenServer.start_link(__MODULE__, %{}, opts)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:start, :file, filename}, _from, state) do
    {:ok, _pid} = Rmc.File.start_link(self(), filename)
    {:reply, :ok, state}
  end

  def handle_call({:start, :udp, port}, _from, state) do
    {:ok, _pid} = Rmc.Udp.start_link(self(), port)
    {:reply, :ok, state}
  end

  def handle_cast(%{packet_header: %{session_time: session_time}} = msg, state) do
    old_session_time = RaceState.get_session_time()
    RaceState.put(msg)

    if session_time != old_session_time do
      broadcast()
    end

    {:noreply, state}
  end

  def broadcast() do
    RmcWeb.Endpoint.broadcast!("telemetry:session", "update", RaceState.get_session())
    RmcWeb.Endpoint.broadcast!("telemetry:timing", "update", %{timing: RaceState.get_timing()})
  end

  def start(name \\ @name) do
    GenServer.call(name, {:start, :file, "858860707279373194.f1"})
  end
end
