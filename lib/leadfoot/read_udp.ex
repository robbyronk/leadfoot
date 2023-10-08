defmodule Leadfoot.ReadUdp do
  @moduledoc false

  use GenServer

  alias Leadfoot.ParsePacket
  alias Phoenix.PubSub

  @server Leadfoot.ReadUdp

  @initial_port 21_337

  @initial_state %{
    file: nil,
    filename: nil,
    port: nil,
    socket: nil,
    status: :off,
    error_reason: nil
  }

  def start_link(state \\ %{}, _opts \\ []) do
    GenServer.start_link(__MODULE__, state, name: @server)
  end

  def start(filename), do: GenServer.cast(@server, {:start, filename})

  def stop, do: GenServer.cast(@server, :stop)

  def status, do: GenServer.call(@server, :status)

  def change_port(port), do: GenServer.call(@server, {:change_port, port})

  @impl true
  def init(_opts) do
    {:ok, @initial_state, {:continue, :open_port}}
  end

  @impl true
  def handle_continue(:open_port, state) do
    {:noreply, open_udp(state, @initial_port)}
  end

  @impl true
  def handle_info({:udp, _socket, _ip, _port, data}, state) do
    event = ParsePacket.parse_packet(data)
    PubSub.broadcast(Leadfoot.PubSub, "session", {:event, event})

    if state.file != nil do
      len = byte_size(data)
      IO.binwrite(state.file, <<len::16>> <> data)
    end

    {:noreply, state}
  end

  @impl true
  def handle_cast({:start, filename}, state) do
    {:ok, file} = File.open(filename, [:write])

    {:noreply, %{state | file: file, filename: filename}}
  end

  @impl true
  def handle_cast(:stop, state) do
    File.close(state.file)
    {:noreply, @initial_state}
  end

  @impl true
  def handle_call(:status, _from, state) do
    {:reply, %{port: state.port}, state}
  end

  @impl true
  def handle_call({:change_port, port}, from, state) do
    handle_call(:status, from, open_udp(state, port))
  end

  def get_udp_ip do
    udp_ip = Application.fetch_env!(:leadfoot, :udp_ip)

    if is_binary(udp_ip) do
      {:ok, u} = :inet.getaddr(to_charlist(udp_ip), :inet)
      u
    else
      udp_ip
    end
  end

  def open_udp(state, port) do
    case :gen_udp.open(port, mode: :binary, ip: get_udp_ip()) do
      {:ok, socket} ->
        Map.merge(state, %{port: port, socket: socket, status: :on, error_reason: nil})

      {:error, reason} ->
        Map.merge(state, %{error_reason: reason, status: :error, port: nil, socket: nil})
    end
  end
end
