defmodule RaceControl.ReadFile do
  @moduledoc """
  Reads packets from a file and publishes them to pubsub.
  """

  # ms
  @pace 6

  # todo change this to read packet, then wait, then send
  #

  use GenServer
  alias RaceControl.ParsePacket
  alias Phoenix.PubSub

  def start_link(state \\ %{}, opts \\ []) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(_opts) do
    {:ok, %{}, {:continue, :open_file}}
  end

  def handle_continue(:open_file, state) do
    {:ok, file} = File.open("session.forza", [:read])
    first_packet = read_packet(file)
    PubSub.broadcast(RaceControl.PubSub, "session", {:event, first_packet})
    Process.send_after(self(), :read_and_publish, @pace)
    {:noreply, Map.put(state, :file, file)}
  end

  def handle_info(:read_and_publish, state) do
    packet = read_packet(state.file)
    PubSub.broadcast(RaceControl.PubSub, "session", {:event, packet})
    Process.send_after(self(), :read_and_publish, @pace)
    {:noreply, state}
  end

  #  def handle_call(_msg, _from, state) do
  #    {:reply, :ok, state}
  #  end
  #
  #  def handle_cast(_msg, state) do
  #    {:noreply, state}
  #  end

  def scratch() do
    # r RaceControl.ReadFile
    f = RaceControl.ReadFile.read("session.forza")
    us = Enum.filter(f, fn x -> :binary.decode_unsigned(x.unknown1) != 0.0 end)
    Enum.each(us, fn x -> IO.inspect({x.unknown1, x.unknown2}) end)

    lap = RaceControl.ReadFile.get_lap(f)
    RaceControl.ReadFile.get_svg_path_from_events(lap)
    # r RaceControl.ReadFile
    lap = RaceControl.ReadFile.get_lap(f, 2)
    svg = RaceControl.ReadFile.get_svg(lap)
    {:ok, file} = File.open("lap.svg", [:write])
    IO.binwrite(file, svg)
    File.close(file)
  end

  def read(file_name) do
    f = File.read!(file_name)
    read_packets(f)
  end

  def read_packets(<<>>), do: []

  def read_packets(<<
        packet_size::16,
        packet::bytes-size(packet_size),
        rest::binary
      >>) do
    [ParsePacket.parse_packet(packet) | read_packets(rest)]
  end

  def read_packet(file) do
    # todo handle :eof from binread
    <<size::16>> = IO.binread(file, 2)

    packet = IO.binread(file, size)
    ParsePacket.parse_packet(packet)
  end
end
