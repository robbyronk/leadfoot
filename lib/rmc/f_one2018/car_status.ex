defmodule Rmc.FOne2018.CarStatus do
  alias __MODULE__
  @moduledoc false

  #struct CarStatusData
  #{
  #    uint8       m_tractionControl;          // 0 (off) - 2 (high)
  #    uint8       m_antiLockBrakes;           // 0 (off) - 1 (on)
  #    uint8       m_fuelMix;                  // Fuel mix - 0 = lean, 1 = standard, 2 = rich, 3 = max
  #    uint8       m_frontBrakeBias;           // Front brake bias (percentage)
  #    uint8       m_pitLimiterStatus;         // Pit limiter status - 0 = off, 1 = on
  #    float       m_fuelInTank;               // Current fuel mass
  #    float       m_fuelCapacity;             // Fuel capacity
  #    uint16      m_maxRPM;                   // Cars max RPM, point of rev limiter
  #    uint16      m_idleRPM;                  // Cars idle RPM
  #    uint8       m_maxGears;                 // Maximum number of gears
  #    uint8       m_drsAllowed;               // 0 = not allowed, 1 = allowed, -1 = unknown
  #    uint8       m_tyresWear[4];             // Tyre wear percentage
  #    uint8       m_tyreCompound;             // Modern - 0 = hyper soft, 1 = ultra soft
  #                                            // 2 = super soft, 3 = soft, 4 = medium, 5 = hard
  #                                            // 6 = super hard, 7 = inter, 8 = wet
  #                                            // Classic - 0-6 = dry, 7-8 = wet
  #    uint8       m_tyresDamage[4];           // Tyre damage (percentage)
  #    uint8       m_frontLeftWingDamage;      // Front left wing damage (percentage)
  #    uint8       m_frontRightWingDamage;     // Front right wing damage (percentage)
  #    uint8       m_rearWingDamage;           // Rear wing damage (percentage)
  #    uint8       m_engineDamage;             // Engine damage (percentage)
  #    uint8       m_gearBoxDamage;            // Gear box damage (percentage)
  #    uint8       m_exhaustDamage;            // Exhaust damage (percentage)
  #    int8        m_vehicleFiaFlags;          // -1 = invalid/unknown, 0 = none, 1 = green
  #                                            // 2 = blue, 3 = yellow, 4 = red
  #    float       m_ersStoreEnergy;           // ERS energy store in Joules
  #    uint8       m_ersDeployMode;            // ERS deployment mode, 0 = none, 1 = low, 2 = medium
  #                                            // 3 = high, 4 = overtake, 5 = hotlap
  #    float       m_ersHarvestedThisLapMGUK;  // ERS energy harvested this lap by MGU-K
  #    float       m_ersHarvestedThisLapMGUH;  // ERS energy harvested this lap by MGU-H
  #    float       m_ersDeployedThisLap;       // ERS energy deployed this lap
  #};

  @derive Jason.Encoder
  defstruct [
    :traction_control,
    :anti_lock_brakes,
    :fuel_mix,
    :front_brake_bias,
    :pit_limiter_status,
    :fuel_in_tank,
    :fuel_capacity,
    :max_rpm,
    :idle_rpm,
    :max_gears,
    :drs_allowed,
    :tyres_wear,
    :tyre_compound,
    :tyre_damage,
    :front_left_wing_damage,
    :front_right_wing_damage,
    :rear_wing_damage,
    :engine_damage,
    :gear_box_damage,
    :exhaust_damage,
    :vehicle_flags,
    :ers_store_energy,
    :ers_deploy_mode,
    :ers_harvested_mguk,
    :ers_harvested_mguh,
    :ers_deployed,
  ]

  def parse_statuses(
        <<
          traction_control :: size(8),
          anti_lock_brakes :: size(8),
          fuel_mix :: size(8),
          front_brake_bias :: size(8),
          pit_limiter_status :: size(8),
          fuel_in_tank :: little - float - size(32),
          fuel_capacity :: little - float - size(32),
          max_rpm :: little - size(16),
          idle_rpm :: little - size(16),
          max_gears :: size(8),
          drs_allowed :: size(8),
          tyres_wear_rl :: size(8),
          tyres_wear_rr :: size(8),
          tyres_wear_fl :: size(8),
          tyres_wear_fr :: size(8),
          tyre_compound :: size(8),
          tyre_damage_rl :: size(8),
          tyre_damage_rr :: size(8),
          tyre_damage_fl :: size(8),
          tyre_damage_fr :: size(8),
          front_left_wing_damage :: size(8),
          front_right_wing_damage :: size(8),
          rear_wing_damage :: size(8),
          engine_damage :: size(8),
          gear_box_damage :: size(8),
          exhaust_damage :: size(8),
          vehicle_flags :: signed - size(8),
          ers_store_energy :: little - float - size(32),
          ers_deploy_mode :: size(8),
          ers_harvested_mguk :: little - float - size(32),
          ers_harvested_mguh :: little - float - size(32),
          ers_deployed :: little - float - size(32),
          statuses :: binary
        >>
      ) do
    [
      %CarStatus{
        traction_control: traction_control,
        anti_lock_brakes: anti_lock_brakes,
        fuel_mix: fuel_mix,
        front_brake_bias: front_brake_bias,
        pit_limiter_status: pit_limiter_status,
        fuel_in_tank: fuel_in_tank,
        fuel_capacity: fuel_capacity,
        max_rpm: max_rpm,
        idle_rpm: idle_rpm,
        max_gears: max_gears,
        drs_allowed: drs_allowed,
        tyres_wear: [
          tyres_wear_rl, tyres_wear_rr, tyres_wear_fl, tyres_wear_fr
        ],
        tyre_compound: tyre_compound,
        tyre_damage: [
          tyre_damage_rl, tyre_damage_rr, tyre_damage_fl, tyre_damage_fr
        ],
        front_left_wing_damage: front_left_wing_damage,
        front_right_wing_damage: front_right_wing_damage,
        rear_wing_damage: rear_wing_damage,
        engine_damage: engine_damage,
        gear_box_damage: gear_box_damage,
        exhaust_damage: exhaust_damage,
        vehicle_flags: vehicle_flags,
        ers_store_energy: ers_store_energy,
        ers_deploy_mode: ers_deploy_mode,
        ers_harvested_mguk: ers_harvested_mguk,
        ers_harvested_mguh: ers_harvested_mguh,
        ers_deployed: ers_deployed,
      } | parse_statuses(statuses)
    ]
  end
  def parse_statuses(<<>>), do: []


end
