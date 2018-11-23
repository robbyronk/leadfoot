defmodule Rmc.FOne2018.PacketHeader do
  alias __MODULE__
  @moduledoc false

  # struct PacketHeader
  # {
  #    uint16    m_packetFormat;         // 2018
  #    uint8     m_packetVersion;        // Version of this packet type, all start from 1
  #    uint8     m_packetId;             // Identifier for the packet type, see below
  #    uint64    m_sessionUID;           // Unique identifier for the session
  #    float     m_sessionTime;          // Session timestamp
  #    uint      m_frameIdentifier;      // Identifier for the frame the data was retrieved on
  #    uint8     m_playerCarIndex;       // Index of player's car in the array
  # };

  # packet ids
  # motion: 0
  # session: 1
  # lap data: 2
  # event: 3
  # participants: 4
  # car setups: 5
  # telemetry: 6
  # car status: 7

  @derive Jason.Encoder
  defstruct [
    :session_uid,
    :session_time,
    :frame_id,
    :player_car_index
  ]

  def parse(<<
        2018::little-size(16),
        1::size(8),
        _packet_id::size(8),
        session_uid::little-size(64),
        session_time::little-float-size(32),
        frame_id::little-size(32),
        player_car_index::size(8),
        rest::bytes
      >>) do
    packet_header = %PacketHeader{
      session_uid: session_uid,
      session_time: session_time,
      frame_id: frame_id,
      player_car_index: player_car_index
    }

    {packet_header, rest}
  end
end
