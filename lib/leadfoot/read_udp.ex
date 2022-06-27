defmodule Leadfoot.ReadUdp do
  @moduledoc false

  use GenServer
  alias Leadfoot.ParsePacket
  alias Phoenix.PubSub

  @initial_state %{
    file: nil
  }

  def start_link(state \\ %{}, opts \\ []) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(_opts) do
    {:ok, @initial_state, {:continue, :open_port}}
  end

  def handle_continue(:open_port, state) do
    # todo allow for port selection at run time
    {:ok, _socket} = :gen_udp.open(21_337, mode: :binary)
    {:noreply, state}
  end

  def handle_info({:udp, _socket, _ip, _port, data}, state) do
    event = ParsePacket.parse_packet(data)
    PubSub.broadcast(Leadfoot.PubSub, "session", {:event, event})

    if state.file != nil do
      len = byte_size(data)
      IO.binwrite(state.file, <<len::16>> <> data)
    end

    {:noreply, state}
  end

  def start(pid, filename) do
    GenServer.cast(pid, {:start, filename})
  end

  def stop(pid) do
    GenServer.cast(pid, :stop)
  end

  def handle_cast({:start, filename}, state) do
    {:ok, file} = File.open(filename, [:write])

    {:noreply, %{state | file: file}}
  end

  def handle_cast(:stop, state) do
    File.close(state.file)
    {:noreply, @initial_state}
  end
end
