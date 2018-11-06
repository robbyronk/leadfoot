defmodule Rmc.File do
  @moduledoc false
  use GenServer
  require Logger

  def start_link(filename \\ "858860707279373194.f1") do
    GenServer.start_link(__MODULE__, filename)
  end

  # {:ok, pid} = Rmc.File.start_link()
  # send(pid, :next)

  def init(filename) do
    Logger.info("Started File")
    packets = File.read!(filename)
    {:ok, %{packets: packets, last_time: :nil}}
  end

  def handle_info(:next, %{packets: packets, last_time: last_time}) do
    {parsed, packets} = read_packet(packets)
    send(parsed)
    %{packet_header: %{session_time: session_time}} = parsed
    IO.inspect({session_time, last_time})

    cond do
      last_time == :nil -> send(self(), :next)
      session_time == last_time -> send(self(), :next)
      true -> Process.send_after(self(), :next, round(abs(session_time - last_time) * 1000))
    end

    {:noreply, %{packets: packets, last_time: session_time}}
  end

  def read_packet(<<>>), do: {}
  def read_packet(
        <<
          packet_size :: 16,
          packet :: bytes - size(packet_size),
          packets :: binary
        >>
      ) do
    {parse_packet(packet), packets}
  end

  def send(parsed), do: RmcWeb.Endpoint.broadcast!("telemetry:f1", "data_point", parsed)

  def parse_packet(data) do
    <<
      2018 :: unsigned - little - size(16),
      1 :: unsigned - size(8),
      packet_id :: unsigned - size(8),
      _rest :: binary
    >> = data

    case packet_id do
      0 -> Rmc.FOne2018.Motion.parse_packet(data)
      1 -> Rmc.FOne2018.Session.parse_packet(data)
      2 -> Rmc.FOne2018.Laps.parse_packet(data)
      3 -> Rmc.FOne2018.Event.parse_packet(data)
      4 -> Rmc.FOne2018.Participants.parse_packet(data)
      5 -> Rmc.FOne2018.CarSetups.parse_packet(data)
      6 -> Rmc.FOne2018.Telemetries.parse_packet(data)
      7 -> Rmc.FOne2018.CarStatuses.parse_packet(data)
      _ -> :nil
    end
  end



end
