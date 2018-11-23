defmodule Rmc.FOne2018.Lap do
  alias __MODULE__
  @moduledoc false

  # struct LapData
  # {
  #    float       m_lastLapTime;           // Last lap time in seconds
  #    float       m_currentLapTime;        // Current time around the lap in seconds
  #    float       m_bestLapTime;           // Best lap time of the session in seconds
  #    float       m_sector1Time;           // Sector 1 time in seconds
  #    float       m_sector2Time;           // Sector 2 time in seconds
  #    float       m_lapDistance;           // Distance vehicle is around current lap in metres – could
  #                                         // be negative if line hasn’t been crossed yet
  #    float       m_totalDistance;         // Total distance travelled in session in metres – could
  #                                         // be negative if line hasn’t been crossed yet
  #    float       m_safetyCarDelta;        // Delta in seconds for safety car
  #    uint8       m_carPosition;           // Car race position
  #    uint8       m_currentLapNum;         // Current lap number
  #    uint8       m_pitStatus;             // 0 = none, 1 = pitting, 2 = in pit area
  #    uint8       m_sector;                // 0 = sector1, 1 = sector2, 2 = sector3
  #    uint8       m_currentLapInvalid;     // Current lap invalid - 0 = valid, 1 = invalid
  #    uint8       m_penalties;             // Accumulated time penalties in seconds to be added
  #    uint8       m_gridPosition;          // Grid position the vehicle started the race in
  #    uint8       m_driverStatus;          // Status of driver - 0 = in garage, 1 = flying lap
  #                                         // 2 = in lap, 3 = out lap, 4 = on track
  #    uint8       m_resultStatus;          // Result status - 0 = invalid, 1 = inactive, 2 = active
  #                                         // 3 = finished, 4 = disqualified, 5 = not classified
  #                                         // 6 = retired
  # };

  @derive Jason.Encoder
  defstruct [
    :last_lap_time,
    :current_lap_time,
    :best_lap_time,
    :sector_one_time,
    :sector_two_time,
    :lap_distance,
    :total_distance,
    :safety_car_delta,
    :car_position,
    :current_lap_num,
    :pit_status,
    :sector,
    :current_lap_invalid,
    :penalties,
    :grid_position,
    :driver_status,
    :result_status
  ]

  def parse_laps(<<
        last_lap_time::little-float-size(32),
        current_lap_time::little-float-size(32),
        best_lap_time::little-float-size(32),
        sector_one_time::little-float-size(32),
        sector_two_time::little-float-size(32),
        lap_distance::little-float-size(32),
        total_distance::little-float-size(32),
        safety_car_delta::little-float-size(32),
        car_position::size(8),
        current_lap_num::size(8),
        pit_status::size(8),
        sector::size(8),
        current_lap_invalid::size(8),
        penalties::size(8),
        grid_position::size(8),
        driver_status::size(8),
        result_status::size(8),
        laps::binary
      >>) do
    [
      %Lap{
        last_lap_time: last_lap_time,
        current_lap_time: current_lap_time,
        best_lap_time: best_lap_time,
        sector_one_time: sector_one_time,
        sector_two_time: sector_two_time,
        lap_distance: lap_distance,
        total_distance: total_distance,
        safety_car_delta: safety_car_delta,
        car_position: car_position,
        current_lap_num: current_lap_num,
        pit_status: pit_status,
        sector: sector,
        current_lap_invalid: current_lap_invalid,
        penalties: penalties,
        grid_position: grid_position,
        driver_status: driver_status,
        result_status: result_status
      }
      | parse_laps(laps)
    ]
  end

  def parse_laps(<<>>), do: []
end
