defmodule Rmc.FOne2018.Event do
  alias __MODULE__
  @moduledoc false

  #struct PacketEventData
  #{
  #    PacketHeader    m_header;               // Header
  #
  #    uint8           m_eventStringCode[4];   // Event string code, see above
  #};

  # code: "SSTA" or "SEND" for start and end

  @derive Jason.Encoder
  defstruct [
    :packet_header,
    :code,
  ]

  def parse_packet(packet) do
    {packet_header, code} = Rmc.FOne2018.PacketHeader.parse(packet)
    %Event{
      packet_header: packet_header,
      code: code,
    }
  end
end
