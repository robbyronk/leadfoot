defmodule Rmc.File do
  @moduledoc """
  Reads packets from a file and sends them in real time
"""
  use GenServer
  require Logger

  def start_link(filename \\ "858860707279373194.f1") do
    GenServer.start_link(__MODULE__, filename)
  end

  # {:ok, pid} = Rmc.File.start_link()
  # send(pid, :next)

  def init(filename) do
    Logger.info("Started File")
    {:ok, dispatcher} = Rmc.ScreenDispatcher.start_link()
    packets = File.read!(filename)
    {:ok, %{packets: packets, last_time: :nil, dispatcher: dispatcher}}
  end

  def handle_info(:next, %{packets: packets, last_time: last_time, dispatcher: dispatcher}) do
    {parsed, packets} = read_packet(packets)
    Rmc.ScreenDispatcher.dispatch(dispatcher, parsed)
    %{packet_header: %{session_time: session_time}} = parsed
#    IO.inspect({session_time, last_time})

    cond do
      last_time == :nil -> send(self(), :next)
      session_time == last_time -> send(self(), :next)
      true -> Process.send_after(self(), :next, round(abs(session_time - last_time) * 1000))
    end

    {:noreply, %{packets: packets, last_time: session_time, dispatcher: dispatcher}}
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
