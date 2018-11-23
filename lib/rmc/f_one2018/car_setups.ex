defmodule Rmc.FOne2018.CarSetups do
  alias __MODULE__
  @moduledoc false

  # struct PacketCarSetupData
  # {
  #    PacketHeader    m_header;            // Header
  #
  #    CarSetupData    m_carSetups[20];
  # };

  @derive Jason.Encoder
  defstruct [
    :packet_header,
    :car_setups
  ]

  def parse_packet(packet) do
    {packet_header, setup_data} = Rmc.FOne2018.PacketHeader.parse(packet)

    %CarSetups{
      packet_header: packet_header,
      car_setups: Rmc.FOne2018.CarSetup.parse_setups(setup_data)
    }
  end
end
