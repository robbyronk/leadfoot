defmodule Rmc.FOne2018.Telemetries do
  alias __MODULE__
  @moduledoc false
  alias Rmc.FOne2018

  # struct PacketCarTelemetryData
  # {
  #    PacketHeader        m_header;                // Header
  #
  #    CarTelemetryData    m_carTelemetryData[20];
  #
  #    uint32              m_buttonStatus;         // Bit flags specifying which buttons are being
  #                                                // pressed currently - see appendices
  # };

  @derive Jason.Encoder
  defstruct [
    :packet_header,
    :telemetries,
    :buttons
  ]

  def parse_packet(packet) do
    {packet_header, telemetry_data} = FOne2018.PacketHeader.parse(packet)

    %Telemetries{
      packet_header: packet_header,
      telemetries:
        FOne2018.Telemetry.parse_telemetries(binary_part(telemetry_data, 0, 20 * 53))
    }
  end
end
