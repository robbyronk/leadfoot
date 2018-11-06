defmodule Rmc.Udp do
  @moduledoc false
  use GenServer
  require Logger

  def start_link() do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(_state) do
    Logger.info("Started UDP")
    {:ok, _socket} = :gen_udp.open(21337)

    {:ok, []}
  end

  # Handle UDP data
  def handle_info({:udp, _socket, _ip, _port, data}, state) do
    bin_data = :binary.list_to_bin(data)
    session_uid = parse_packet(bin_data)
    {:noreply, write_packet(session_uid, bin_data, state)}
  end


  def write_packet(session_uid, data, []) do
    IO.inspect("session: #{session_uid}")
    {:ok, file} = File.open("#{session_uid}.f1", [:write])
    write_packet(session_uid, data, [session_uid, file])
  end
  def write_packet(session_uid, data, [other_uid, file]) when session_uid != other_uid do
    IO.inspect("ending session #{other_uid} for #{session_uid}")
    File.close(file)
    write_packet(session_uid, data, [])
  end
  def write_packet(session_uid, data, [session_uid, file]) do
    size = byte_size(data)
    IO.inspect("writing #{size + 2} bytes")
    IO.binwrite(file, <<size :: 16>> <> data)
    [session_uid, file]
  end

  def parse_packet(data) do
    <<
      packet_format :: unsigned - little - size(16),
      packet_version :: unsigned - size(8),
      packet_id :: unsigned - size(8),
      session_uid :: unsigned - little - size(64),
      session_time :: little - float - size(32),
      frame_id :: unsigned - little - integer - size(32),
      player_car_index :: unsigned - size(8),
      _rest :: binary
    >> = data

    data = case packet_id do
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

    RmcWeb.Endpoint.broadcast!("telemetry:f1", "data_point", data)

    session_uid
  end
end
