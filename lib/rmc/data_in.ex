defmodule Rmc.DataIn do
  @moduledoc """
  GenStage Producer to take in raw packets
  """
  use GenStage
  @name __MODULE__

  def start_link do
    GenStage.start_link(@name, :ok, name: @name)
  end

  def init(:ok) do
    {:producer, []}
  end

  def handle_call({:start, :file, filename}, _from, state) do
    {:ok, _pid} = Rmc.File.start_link(self(), filename)
    {:reply, :ok, state}
  end

  def handle_call({:start, :udp, port}, _from, state) do
    {:ok, _pid} = Rmc.Udp.start_link(self(), port)
    {:reply, :ok, state}
  end

  def handle_cast(packet, state) do
    Rmc.DataIn.add([packet])

    {:noreply, state}
  end

  def add(packets), do: GenServer.cast(__MODULE__, {:add, packets})

  # just push events to consumers on adding
  def handle_cast({:add, packets}, state) when is_list(packets) do
    {:noreply, packets, state}
  end
  def handle_cast({:add, packets}, state), do: {:noreply, [packets], state}

  # ignore any demand
  def handle_demand(_, state), do: {:noreply, [], state}

  def start(name \\ @name) do
    GenServer.call(name, {:start, :file, "858860707279373194.f1"})
  end
end
