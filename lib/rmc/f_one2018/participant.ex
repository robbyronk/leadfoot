defmodule Rmc.FOne2018.Participant do
  alias __MODULE__
  @moduledoc false

  #struct ParticipantData
  #{
  #    uint8      m_aiControlled;           // Whether the vehicle is AI (1) or Human (0) controlled
  #    uint8      m_driverId;               // Driver id - see appendix
  #    uint8      m_teamId;                 // Team id - see appendix
  #    uint8      m_raceNumber;             // Race number of the car
  #    uint8      m_nationality;            // Nationality of the driver
  #    char       m_name[48];               // Name of participant in UTF-8 format – null terminated
  #                                         // Will be truncated with … (U+2026) if too long
  #};

  @derive Jason.Encoder
  defstruct [
    :ai_controlled,
    :driver_id,
    :team_id,
    :race_number,
    :nationality,
    :name,
  ]

  def parse_participants(
        <<
          ai_controlled :: size(8),
          driver_id :: size(8),
          team_id :: size(8),
          race_number :: size(8),
          nationality :: size(8),
          name :: binary - size(48),
          participants_data :: binary
        >>
      ) do
    [
      %Participant{
        ai_controlled: ai_controlled,
        driver_id: driver_id,
        team_id: team_id,
        race_number: race_number,
        nationality: nationality,
        name: String.trim(name, <<0>>),
      } | parse_participants(participants_data)
    ]
  end
  def parse_participants(<<>>), do: []

end
