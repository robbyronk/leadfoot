defmodule Rmc.File do
  @moduledoc """
    Reads packets from a file and sends them in real time
  """
  use GenServer
  require Logger
  alias Rmc.RaceState

  def start_link(parent_pid, filename) do
    GenServer.start_link(__MODULE__, {parent_pid, filename})
  end

  def init({parent_pid, filename}) do
    Logger.info("Started File")
    packets = File.read!(filename)
    Process.send_after(self(), :start, 1000)
    {:ok, %{parent_pid: parent_pid, packets: packets, next_packet: nil}}
  end

  def handle_info(:start, %{packets: packets} = state) do
    {next_packet, packets} = read_packet(packets)
    send(self(), :next)
    {:noreply, %{state | packets: packets, next_packet: next_packet}}
  end

  def handle_info(:next, %{parent_pid: parent_pid, packets: packets, next_packet: this_packet}) do
    %{packet_header: %{session_time: this_time}} = this_packet
    GenServer.cast(parent_pid, this_packet)
    {next_packet, packets} = read_packet(packets)
    %{packet_header: %{session_time: next_time}} = next_packet

    if next_time > this_time do
      Process.send_after(self(), :next, round((next_time - this_time) * 1000))
    else
      send(self(), :next)
    end

    {:noreply, %{parent_pid: parent_pid, packets: packets, next_packet: next_packet}}
  end

  def read_packet(<<>>), do: {}

  def read_packet(<<
        packet_size::16,
        packet::bytes-size(packet_size),
        packets::binary
      >>) do
    {Rmc.ParsePacket.parse_packet(packet), packets}
  end
end
