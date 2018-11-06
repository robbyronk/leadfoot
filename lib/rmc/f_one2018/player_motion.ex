defmodule Rmc.FOne2018.PlayerMotion do
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
    :suspension_position,
    :suspension_velocity,
    :suspension_acceleration,
    :wheel_speed,
    :wheel_slip,
    :front_wheels_angle,
  ]

  def parse(
        <<
          suspension_position_rl :: little - float - size(32),
          suspension_position_rr :: little - float - size(32),
          suspension_position_fl :: little - float - size(32),
          suspension_position_fr :: little - float - size(32),
          suspension_velocity_rl :: little - float - size(32),
          suspension_velocity_rr :: little - float - size(32),
          suspension_velocity_fl :: little - float - size(32),
          suspension_velocity_fr :: little - float - size(32),
          suspension_acceleration_rl :: little - float - size(32),
          suspension_acceleration_rr :: little - float - size(32),
          suspension_acceleration_fl :: little - float - size(32),
          suspension_acceleration_fr :: little - float - size(32),
          wheel_speed_rl :: little - float - size(32),
          wheel_speed_rr :: little - float - size(32),
          wheel_speed_fl :: little - float - size(32),
          wheel_speed_fr :: little - float - size(32),
          wheel_slip_rl :: little - float - size(32),
          wheel_slip_rr :: little - float - size(32),
          wheel_slip_fl :: little - float - size(32),
          wheel_slip_fr :: little - float - size(32),
          _local_velocity_x :: little - float - size(32),
          _local_velocity_y :: little - float - size(32),
          _local_velocity_z :: little - float - size(32),
          _angular_velocity_x :: little - float - size(32),
          _angular_velocity_y :: little - float - size(32),
          _angular_velocity_z :: little - float - size(32),
          _angular_acceleration_x :: little - float - size(32),
          _angular_acceleration_y :: little - float - size(32),
          _angular_acceleration_z :: little - float - size(32),
          front_wheels_angle :: little - float - size(32),
        >>
      ) do
    %PlayerMotion{
      suspension_position: [
        suspension_position_rl,
        suspension_position_rr,
        suspension_position_fl,
        suspension_position_fr,
      ],
      suspension_velocity: [
        suspension_velocity_rl,
        suspension_velocity_rr,
        suspension_velocity_fl,
        suspension_velocity_fr,
      ],
      suspension_acceleration: [
        suspension_acceleration_rl,
        suspension_acceleration_rr,
        suspension_acceleration_fl,
        suspension_acceleration_fr,
      ],
      wheel_speed: [
        wheel_speed_rl,
        wheel_speed_rr,
        wheel_speed_fl,
        wheel_speed_fr,
      ],
      wheel_slip: [
        wheel_slip_rl,
        wheel_slip_rr,
        wheel_slip_fl,
        wheel_slip_fr,
      ],
      front_wheels_angle: front_wheels_angle,
    }
  end
end
