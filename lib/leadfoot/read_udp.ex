defmodule Leadfoot.ReadUdp do
  @moduledoc false

  use GenServer
  alias Leadfoot.ParsePacket
  alias Phoenix.PubSub

  def start_link(state \\ %{}, opts \\ []) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(_opts) do
    {:ok, %{}, {:continue, :open_port}}
  end

  def handle_continue(:open_port, state) do
    # todo allow for port selection at run time
    {:ok, _socket} = :gen_udp.open(21_337, mode: :binary)
    {:noreply, state}
  end

  def handle_info({:udp, _socket, _ip, _port, data}, state) do
    event = ParsePacket.parse_packet(data)
    PubSub.broadcast(Leadfoot.PubSub, "session", {:event, event})
    {:noreply, state}
  end
end
