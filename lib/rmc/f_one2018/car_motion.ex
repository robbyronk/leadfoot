defmodule Rmc.FOne2018.CarMotion do
  alias __MODULE__
  @moduledoc false

  # struct CarMotionData
  # {
  #    float         m_worldPositionX;           // World space X position
  #    float         m_worldPositionY;           // World space Y position
  #    float         m_worldPositionZ;           // World space Z position
  #    float         m_worldVelocityX;           // Velocity in world space X
  #    float         m_worldVelocityY;           // Velocity in world space Y
  #    float         m_worldVelocityZ;           // Velocity in world space Z
  #    int16         m_worldForwardDirX;         // World space forward X direction (normalised)
  #    int16         m_worldForwardDirY;         // World space forward Y direction (normalised)
  #    int16         m_worldForwardDirZ;         // World space forward Z direction (normalised)
  #    int16         m_worldRightDirX;           // World space right X direction (normalised)
  #    int16         m_worldRightDirY;           // World space right Y direction (normalised)
  #    int16         m_worldRightDirZ;           // World space right Z direction (normalised)
  #    float         m_gForceLateral;            // Lateral G-Force component
  #    float         m_gForceLongitudinal;       // Longitudinal G-Force component
  #    float         m_gForceVertical;           // Vertical G-Force component
  #    float         m_yaw;                      // Yaw angle in radians
  #    float         m_pitch;                    // Pitch angle in radians
  #    float         m_roll;                     // Roll angle in radians
  # };

  @derive Jason.Encoder
  defstruct [
    :position,
    :velocity,
    :forward_dir,
    :right_dir,
    :g_force_lateral,
    :g_force_longitudinal,
    :g_force_vertical,
    :yaw,
    :pitch,
    :roll
  ]

  def parse_motions(<<
        position_x::little-float-size(32),
        position_y::little-float-size(32),
        position_z::little-float-size(32),
        velocity_x::little-float-size(32),
        velocity_y::little-float-size(32),
        velocity_z::little-float-size(32),
        forward_dir_x::little-size(16),
        forward_dir_y::little-size(16),
        forward_dir_z::little-size(16),
        right_dir_x::little-size(16),
        right_dir_y::little-size(16),
        right_dir_z::little-size(16),
        g_force_lateral::little-float-size(32),
        g_force_longitudinal::little-float-size(32),
        g_force_vertical::little-float-size(32),
        yaw::little-float-size(32),
        pitch::little-float-size(32),
        roll::little-float-size(32),
        motions::binary
      >>) do
    [
      %CarMotion{
        position: [
          position_x,
          position_y,
          position_z
        ],
        velocity: [
          velocity_x,
          velocity_y,
          velocity_z
        ],
        forward_dir: [
          forward_dir_x,
          forward_dir_y,
          forward_dir_z
        ],
        right_dir: [
          right_dir_x,
          right_dir_y,
          right_dir_z
        ],
        g_force_lateral: g_force_lateral,
        g_force_longitudinal: g_force_longitudinal,
        g_force_vertical: g_force_vertical,
        yaw: yaw,
        pitch: pitch,
        roll: roll
      }
      | parse_motions(motions)
    ]
  end

  def parse_motions(<<>>), do: []
end
