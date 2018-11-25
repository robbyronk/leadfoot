defmodule Rmc.FOne2018.Session do
  alias __MODULE__
  @moduledoc false
  alias Rmc.FOne2018

  # struct PacketSessionData
  # {
  #    PacketHeader    m_header;               	// Header
  #
  #    uint8           m_weather;              	// Weather - 0 = clear, 1 = light cloud, 2 = overcast
  #                                            	// 3 = light rain, 4 = heavy rain, 5 = storm
  #    int8	    m_trackTemperature;    	// Track temp. in degrees celsius
  #    int8	    m_airTemperature;      	// Air temp. in degrees celsius
  #    uint8           m_totalLaps;           	// Total number of laps in this race
  #    uint16          m_trackLength;           	// Track length in metres
  #    uint8           m_sessionType;         	// 0 = unknown, 1 = P1, 2 = P2, 3 = P3, 4 = Short P
  #                                            	// 5 = Q1, 6 = Q2, 7 = Q3, 8 = Short Q, 9 = OSQ
  #                                            	// 10 = R, 11 = R2, 12 = Time Trial
  #    int8            m_trackId;         		// -1 for unknown, 0-21 for tracks, see appendix
  #    uint8           m_era;                  	// Era, 0 = modern, 1 = classic
  #    uint16          m_sessionTimeLeft;    	// Time left in session in seconds
  #    uint16          m_sessionDuration;     	// Session duration in seconds
  #    uint8           m_pitSpeedLimit;      	// Pit speed limit in kilometres per hour
  #    uint8           m_gamePaused;               // Whether the game is paused
  #    uint8           m_isSpectating;        	// Whether the player is spectating
  #    uint8           m_spectatorCarIndex;  	// Index of the car being spectated
  #    uint8           m_sliProNativeSupport;	// SLI Pro support, 0 = inactive, 1 = active
  #    uint8           m_numMarshalZones;         	// Number of marshal zones to follow
  #    MarshalZone     m_marshalZones[21];         // List of marshal zones – max 21
  #    uint8           m_safetyCarStatus;          // 0 = no safety car, 1 = full safety car
  #                                                // 2 = virtual safety car
  #    uint8          m_networkGame;              // 0 = offline, 1 = online
  # };

  @derive Jason.Encoder
  defstruct [
    :packet_header,
    :weather,
    :track_temperature,
    :air_temperature,
    :total_laps,
    :track_length,
    :session_type,
    :track_id,
    :era,
    :time_left,
    :duration,
    :pit_speed_limit,
    :game_paused,
    :is_spectating,
    :spectator_car_index,
    :marshal_zones,
    :safety_car_status,
    :network_game
  ]

  def parse_marshal_zones(<<
        start::little-float-size(32),
        flag::signed-size(8),
        rest::binary
      >>) do
    [%FOne2018.MarshalZone{start: start, flag: flag} | parse_marshal_zones(rest)]
  end

  def parse_marshal_zones(_), do: []

  def parse_packet(packet) do
    {packet_header, session_data} = FOne2018.PacketHeader.parse(packet)

    <<
      weather::size(8),
      track_temperature::signed-size(8),
      air_temperature::signed-size(8),
      total_laps::size(8),
      track_length::little-size(16),
      session_type::size(8),
      track_id::signed-size(8),
      era::size(8),
      time_left::little-size(16),
      duration::little-size(16),
      pit_speed_limit::size(8),
      game_paused::size(8),
      is_spectating::size(8),
      spectator_car_index::size(8),
      _sli_pro::size(8),
      num_marshal_zones::size(8),
      rest::binary
    >> = session_data

    zones = parse_marshal_zones(binary_part(rest, 0, 5 * 21))

    <<
      safety_car_status::size(8),
      network_game::size(8)
    >> = binary_part(rest, 5 * 21, 2)

    %Session{
      packet_header: packet_header,
      weather: weather,
      track_temperature: track_temperature,
      air_temperature: air_temperature,
      total_laps: total_laps,
      track_length: track_length,
      session_type: session_type,
      track_id: track_id,
      era: era,
      time_left: time_left,
      duration: duration,
      pit_speed_limit: pit_speed_limit,
      game_paused: game_paused,
      is_spectating: is_spectating,
      spectator_car_index: spectator_car_index,
      marshal_zones: Enum.take(zones, num_marshal_zones),
      safety_car_status: safety_car_status,
      network_game: network_game
    }
  end
end
