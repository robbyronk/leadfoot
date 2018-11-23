defmodule Rmc.FOne2018.Participants do
  alias __MODULE__
  @moduledoc false

  # struct PacketParticipantsData
  # {
  #    PacketHeader    m_header;            // Header
  #
  #    uint8           m_numCars;           // Number of cars in the data
  #    ParticipantData m_participants[20];
  # };

  @derive Jason.Encoder
  defstruct [
    :packet_header,
    :num_cars,
    :participants
  ]

  def parse_packet(packet) do
    {packet_header, participants_data} = Rmc.FOne2018.PacketHeader.parse(packet)

    <<
      num_cars::size(8),
      participants_data::binary
    >> = participants_data

    %Participants{
      packet_header: packet_header,
      num_cars: num_cars,
      participants: Rmc.FOne2018.Participant.parse_participants(participants_data)
    }
  end
end
