defmodule Rmc.ParsePacket do
  alias Rmc.FOne2018

  @moduledoc """
    Sends the packet to the correct parser
  """
  def parse_packet(
        <<
          2018::unsigned-little-size(16),
          1::unsigned-size(8),
          packet_id::unsigned-size(8),
          _rest::binary
        >> = data
      ) do
    case packet_id do
      0 -> FOne2018.Motion.parse_packet(data)
      1 -> FOne2018.Session.parse_packet(data)
      2 -> FOne2018.Laps.parse_packet(data)
      3 -> FOne2018.Event.parse_packet(data)
      4 -> FOne2018.Participants.parse_packet(data)
      5 -> FOne2018.CarSetups.parse_packet(data)
      6 -> FOne2018.Telemetries.parse_packet(data)
      7 -> FOne2018.CarStatuses.parse_packet(data)
      _ -> nil
    end
  end
end
