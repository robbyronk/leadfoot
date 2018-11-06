defmodule Rmc.FOne2018.CarStatuses do
  alias __MODULE__
  @moduledoc false

  #struct PacketCarStatusData
  #{
  #    PacketHeader        m_header;            // Header
  #
  #    CarStatusData       m_carStatusData[20];
  #};

  @derive Jason.Encoder
  defstruct [
    :packet_header,
    :statuses,
  ]

  def parse_packet(packet) do
    {packet_header, status_data} = Rmc.FOne2018.PacketHeader.parse(packet)
    %CarStatuses{
      packet_header: packet_header,
      statuses: Rmc.FOne2018.CarStatus.parse_statuses(status_data)
    }
  end
end
