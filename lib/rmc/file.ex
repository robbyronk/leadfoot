defmodule Rmc.File do
  @moduledoc """
    Reads packets from a file and sends them in real time
  """
  use GenStage
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
    this_time = read_session_time(this_packet)
    GenServer.cast(parent_pid, this_packet)
    {next_packet, packets} = read_packet(packets)
    next_time = read_session_time(next_packet)

    if next_time > this_time do
      # todo consider https://github.com/SchedEx/SchedEx run_in function to enable testing
      Process.send_after(self(), :next, round((next_time - this_time) * 1000))
    else
      send(self(), :next)
    end

    {:noreply, %{parent_pid: parent_pid, packets: packets, next_packet: next_packet}}
  end

  def read_session_time(<<
    2018::little-size(16),
    1::size(8),
    _packet_id::size(8),
    _session_uid::little-size(64),
    session_time::little-float-size(32),
    rest::bytes
  >>) do
    session_time
  end

  def read_packet(<<>>), do: {}
  def read_packet(<<
        packet_size::16,
        packet::bytes-size(packet_size),
        packets::binary
      >>) do
    {packet, packets}
  end
end
