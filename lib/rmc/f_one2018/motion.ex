defmodule Rmc.FOne2018.Motion do
  alias __MODULE__
  @moduledoc false

  #struct PacketMotionData
  #{
  #    PacketHeader    m_header;               // Header
  #
  #    CarMotionData   m_carMotionData[20];    // Data for all cars on track
  #
  #    // Extra player car ONLY data
  #    float         m_suspensionPosition[4];       // Note: All wheel arrays have the following order:
  #    float         m_suspensionVelocity[4];       // RL, RR, FL, FR
  #    float         m_suspensionAcceleration[4];   // RL, RR, FL, FR
  #    float         m_wheelSpeed[4];               // Speed of each wheel
  #    float         m_wheelSlip[4];                // Slip ratio for each wheel
  #    float         m_localVelocityX;              // Velocity in local space
  #    float         m_localVelocityY;              // Velocity in local space
  #    float         m_localVelocityZ;              // Velocity in local space
  #    float         m_angularVelocityX;            // Angular velocity x-component
  #    float         m_angularVelocityY;            // Angular velocity y-component
  #    float         m_angularVelocityZ;            // Angular velocity z-component
  #    float         m_angularAccelerationX;        // Angular velocity x-component
  #    float         m_angularAccelerationY;        // Angular velocity y-component
  #    float         m_angularAccelerationZ;        // Angular velocity z-component
  #    float         m_frontWheelsAngle;            // Current front wheels angle in radians
  #};

  @derive Jason.Encoder
  defstruct [
    :packet_header,
    :motions,
    :player_motion,

  ]

  def parse_packet(packet) do
    {packet_header, <<motion_data :: binary - size(1200), player_motion :: binary>>} = Rmc.FOne2018.PacketHeader.parse(
      packet
    )
    %Motion{
      packet_header: packet_header,
      motions: Rmc.FOne2018.CarMotion.parse_motions(motion_data),
      player_motion: Rmc.FOne2018.PlayerMotion.parse(player_motion),
    }
  end
end
