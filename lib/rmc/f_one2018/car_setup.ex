defmodule Rmc.FOne2018.CarSetup do
  alias __MODULE__
  @moduledoc false

  #struct CarSetupData
  #{
  #    uint8     m_frontWing;                // Front wing aero
  #    uint8     m_rearWing;                 // Rear wing aero
  #    uint8     m_onThrottle;               // Differential adjustment on throttle (percentage)
  #    uint8     m_offThrottle;              // Differential adjustment off throttle (percentage)
  #    float     m_frontCamber;              // Front camber angle (suspension geometry)
  #    float     m_rearCamber;               // Rear camber angle (suspension geometry)
  #    float     m_frontToe;                 // Front toe angle (suspension geometry)
  #    float     m_rearToe;                  // Rear toe angle (suspension geometry)
  #    uint8     m_frontSuspension;          // Front suspension
  #    uint8     m_rearSuspension;           // Rear suspension
  #    uint8     m_frontAntiRollBar;         // Front anti-roll bar
  #    uint8     m_rearAntiRollBar;          // Front anti-roll bar
  #    uint8     m_frontSuspensionHeight;    // Front ride height
  #    uint8     m_rearSuspensionHeight;     // Rear ride height
  #    uint8     m_brakePressure;            // Brake pressure (percentage)
  #    uint8     m_brakeBias;                // Brake bias (percentage)
  #    float     m_frontTyrePressure;        // Front tyre pressure (PSI)
  #    float     m_rearTyrePressure;         // Rear tyre pressure (PSI)
  #    uint8     m_ballast;                  // Ballast
  #    float     m_fuelLoad;                 // Fuel load
  #};

  @derive Jason.Encoder
  defstruct [
    :front_wing,
    :rear_wing,
    :on_throttle,
    :off_throttle,
    :front_camber,
    :rear_camber,
    :front_toe,
    :rear_toe,
    :front_suspension,
    :rear_suspension,
    :front_anti_roll_bar,
    :road_anti_roll_bar,
    :front_suspension_height,
    :rear_suspension_height,
    :brake_pressure,
    :brake_bias,
    :front_tyre_pressure,
    :rear_tyre_pressure,
    :ballast,
    :fuel_load,
  ]

  def parse_setups(
        <<
          front_wing :: size(8),
          rear_wing :: size(8),
          on_throttle :: size(8),
          off_throttle :: size(8),
          front_camber :: little - float - size(32),
          rear_camber :: little - float - size(32),
          front_toe :: little - float - size(32),
          rear_toe :: little - float - size(32),
          front_suspension :: size(8),
          rear_suspension :: size(8),
          front_anti_roll_bar :: size(8),
          road_anti_roll_bar :: size(8),
          front_suspension_height :: size(8),
          rear_suspension_height :: size(8),
          brake_pressure :: size(8),
          brake_bias :: size(8),
          front_tyre_pressure :: little - float - size(32),
          rear_tyre_pressure :: little - float - size(32),
          ballast :: size(8),
          fuel_load :: little - float - size(32),
          setups :: binary,
        >>
      ) do
    [
      %CarSetup{
        front_wing: front_wing,
        rear_wing: rear_wing,
        on_throttle: on_throttle,
        off_throttle: off_throttle,
        front_camber: front_camber,
        rear_camber: rear_camber,
        front_toe: front_toe,
        rear_toe: rear_toe,
        front_suspension: front_suspension,
        rear_suspension: rear_suspension,
        front_anti_roll_bar: front_anti_roll_bar,
        road_anti_roll_bar: road_anti_roll_bar,
        front_suspension_height: front_suspension_height,
        rear_suspension_height: rear_suspension_height,
        brake_pressure: brake_pressure,
        brake_bias: brake_bias,
        front_tyre_pressure: front_tyre_pressure,
        rear_tyre_pressure: rear_tyre_pressure,
        ballast: ballast,
        fuel_load: fuel_load,
      }
      | parse_setups(setups)
    ]
  end
  def parse_setups(<<>>), do: []
end
