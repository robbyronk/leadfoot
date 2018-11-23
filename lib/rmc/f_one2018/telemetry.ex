defmodule Rmc.FOne2018.Telemetry do
  alias __MODULE__
  @moduledoc false

  # struct CarTelemetryData
  # {
  #    uint16    m_speed;                      // Speed of car in kilometres per hour
  #    uint8     m_throttle;                   // Amount of throttle applied (0 to 100)
  #    int8      m_steer;                      // Steering (-100 (full lock left) to 100 (full lock right))
  #    uint8     m_brake;                      // Amount of brake applied (0 to 100)
  #    uint8     m_clutch;                     // Amount of clutch applied (0 to 100)
  #    int8      m_gear;                       // Gear selected (1-8, N=0, R=-1)
  #    uint16    m_engineRPM;                  // Engine RPM
  #    uint8     m_drs;                        // 0 = off, 1 = on
  #    uint8     m_revLightsPercent;           // Rev lights indicator (percentage)
  #    uint16    m_brakesTemperature[4];       // Brakes temperature (celsius)
  #    uint16    m_tyresSurfaceTemperature[4]; // Tyres surface temperature (celsius)
  #    uint16    m_tyresInnerTemperature[4];   // Tyres inner temperature (celsius)
  #    uint16    m_engineTemperature;          // Engine temperature (celsius)
  #    float     m_tyresPressure[4];           // Tyres pressure (PSI)
  # };

  @derive Jason.Encoder
  defstruct [
    :speed,
    :throttle,
    :steer,
    :brake,
    :clutch,
    :gear,
    :engine_rpm,
    :drs,
    :rev_lights_percent,
    :brakes_temperature,
    :tyres_outer_temperature,
    :tyres_inner_temperature,
    :engine_temperature,
    :tyres_pressure
  ]

  def parse_telemetries(<<
        speed::little-size(16),
        throttle::size(8),
        steer::signed-size(8),
        brake::size(8),
        clutch::size(8),
        gear::signed-size(8),
        engine_rpm::little-size(16),
        drs::size(8),
        rev_lights_percent::size(8),
        brakes_temperature_rl::little-size(16),
        brakes_temperature_rr::little-size(16),
        brakes_temperature_fl::little-size(16),
        brakes_temperature_fr::little-size(16),
        tyres_outer_temperature_rl::little-size(16),
        tyres_outer_temperature_rr::little-size(16),
        tyres_outer_temperature_fl::little-size(16),
        tyres_outer_temperature_fr::little-size(16),
        tyres_inner_temperature_rl::little-size(16),
        tyres_inner_temperature_rr::little-size(16),
        tyres_inner_temperature_fl::little-size(16),
        tyres_inner_temperature_fr::little-size(16),
        engine_temperature::little-size(16),
        tyres_pressure_rl::little-float-size(32),
        tyres_pressure_rr::little-float-size(32),
        tyres_pressure_fl::little-float-size(32),
        tyres_pressure_fr::little-float-size(32),
        telemetries::binary
      >>) do
    [
      %Telemetry{
        speed: speed,
        throttle: throttle,
        steer: steer,
        brake: brake,
        clutch: clutch,
        gear: gear,
        engine_rpm: engine_rpm,
        drs: drs,
        rev_lights_percent: rev_lights_percent,
        brakes_temperature: [
          brakes_temperature_rl,
          brakes_temperature_rr,
          brakes_temperature_fl,
          brakes_temperature_fr
        ],
        tyres_outer_temperature: [
          tyres_outer_temperature_rl,
          tyres_outer_temperature_rr,
          tyres_outer_temperature_fl,
          tyres_outer_temperature_fr
        ],
        tyres_inner_temperature: [
          tyres_inner_temperature_rl,
          tyres_inner_temperature_rr,
          tyres_inner_temperature_fl,
          tyres_inner_temperature_fr
        ],
        engine_temperature: engine_temperature,
        tyres_pressure: [
          tyres_pressure_rl,
          tyres_pressure_rr,
          tyres_pressure_fl,
          tyres_pressure_fr
        ]
      }
      | parse_telemetries(telemetries)
    ]
  end

  def parse_telemetries(<<>>), do: []
end
