defmodule Rmc.InspectOut do
  @moduledoc """
  GenStage Consumer for printing bits of state to the console for testing
  """

  use GenStage

  def start_link do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:consumer, :_state, subscribe_to: [Rmc.ParsePacket]}
  end

  def handle_events(events, _from, state) do
    IO.inspect("got a packet!")
    {:noreply, [], state}
  end
end
