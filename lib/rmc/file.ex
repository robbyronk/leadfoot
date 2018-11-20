defmodule Rmc.File do
  @moduledoc """
  Reads packets from a file and sends them in real time
"""
  use GenServer
  require Logger
  alias Rmc.RaceState

  def start_link(filename \\ "858860707279373194.f1") do
    GenServer.start_link(__MODULE__, filename)
  end

  # {:ok, pid} = Rmc.File.start_link()
  # send(pid, :start)

  def init(filename) do
    Logger.info("Started File")
    packets = File.read!(filename)
    {:ok, %{packets: packets, next_packet: :nil}}
  end

  def handle_info(:start, %{packets: packets}) do
    {next_packet, packets} = read_packet(packets)
    send(self(), :next)
    {:noreply, %{packets: packets, next_packet: next_packet}}
  end

  def handle_info(:next, %{packets: packets, next_packet: this_packet}) do
    %{packet_header: %{session_time: this_time}} = this_packet
    RaceState.put(this_packet)
    {next_packet, packets} = read_packet(packets)
    %{packet_header: %{session_time: next_time}} = next_packet
    if next_time > this_time do
      broadcast()
      Process.send_after(self(), :next, round((next_time - this_time) * 1000))
    else
      send(self(), :next)
    end
    {:noreply, %{packets: packets, next_packet: next_packet}}
  end

  # TODO move broadcasting and RaceState usages to a module to share between file and udp
  def broadcast() do
    RmcWeb.Endpoint.broadcast!("telemetry:session", "update", RaceState.get_session())
    RmcWeb.Endpoint.broadcast!("telemetry:timing", "update", %{timing: RaceState.get_timing()})
  end

  def read_packet(<<>>), do: {}
  def read_packet(
        <<
          packet_size :: 16,
          packet :: bytes - size(packet_size),
          packets :: binary
        >>
      ) do
    {Rmc.ParsePacket.parse_packet(packet), packets}
  end
end
