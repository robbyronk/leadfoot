defmodule RaceControl.ReadUdp do
  @moduledoc false

  use GenServer
  alias RaceControl.ParsePacket
  alias Phoenix.PubSub

  def start_link(state \\ %{}, opts \\ []) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(_opts) do
    {:ok, %{}, {:continue, :open_port}}
  end

  def handle_continue(:open_port, state) do
    {:ok, _socket} = :gen_udp.open(21_337)
    {:noreply, state}
  end

  def handle_info({:udp, _socket, _ip, _port, data}, state) do
    event =
      data
      |> :binary.list_to_bin()
      |> ParsePacket.parse_packet()

    PubSub.broadcast(RaceControl.PubSub, "session", {:event, event})
    {:noreply, state}
  end
end
