defmodule Rmc.FOne2018.Laps do
  alias __MODULE__
  @moduledoc false

  # struct PacketLapData
  # {
  #    PacketHeader    m_header;              // Header
  #
  #    LapData         m_lapData[20];         // Lap data for all cars on track
  # };

  @derive Jason.Encoder
  defstruct [
    :packet_header,
    :laps
  ]

  def parse_packet(packet) do
    {packet_header, lap_data} = Rmc.FOne2018.PacketHeader.parse(packet)

    %Laps{
      packet_header: packet_header,
      laps: Rmc.FOne2018.Lap.parse_laps(lap_data)
    }
  end
end
