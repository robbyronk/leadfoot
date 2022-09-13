defmodule Leadfoot.LapTimes do
  @moduledoc """
  Captures lap times.

  Lap times are a map with keys :lap and :time.
  """

  use GenServer

  @server Leadfoot.LapTimes

  @initial_state %{
    current_lap: 1,
    lap_times: []
  }

  def start_link(state \\ %{}) do
    GenServer.start_link(__MODULE__, state, name: @server)
  end

  def get_lap_times(), do: GenServer.call(@server, :get_lap_times)

  def reset(), do: GenServer.cast(@server, :reset)

  @impl true
  def init(_opts) do
    Phoenix.PubSub.subscribe(Leadfoot.PubSub, "session")

    {:ok, @initial_state}
  end

  @impl true
  def handle_info({:event, %{lap: 0}}, state), do: {:noreply, state}

  @impl true
  def handle_info({:event, event}, state) do
    {:noreply, capture_lap_time(event, state)}
  end

  @impl true
  def handle_call(:get_lap_times, _from, state), do: {:reply, state.lap_times, state}

  @impl true
  def handle_cast(:reset, _state), do: {:noreply, @initial_state}

  def capture_lap_time(last_lap, %{lap_times: [last_lap | _rest]} = state), do: state

  def capture_lap_time(last_lap, state) do
    Phoenix.PubSub.broadcast(Leadfoot.PubSub, "session:lap_times", last_lap)
    %{state | lap_times: [last_lap | state.lap_times]}
  end
end
