defmodule Rmc.DispatchRaceState do
  @moduledoc """
  This gen stage producer/consumer dispatches partitioned events
  """
  use GenStage # todo
  alias Rmc.FOne2018
  @name __MODULE__



  def get_session(name \\ @name) do
    fields = [
      :total_laps,
      :track_temperature,
      :air_temperature,
      :weather,
      :session_type,
      :track_id
    ]

    Agent.get(name, &Map.take(&1, fields))
  end

  def get_timing(name \\ @name) do
    fields = [
      :car_position,
      :laps,
      :tyre_compound,
      :best_lap_time,
      :last_lap_time,
      :sector_one_time,
      :sector_two_time,
      :sector_three_time,
      :name,
      :race_number
    ]

    Agent.get(name, fn state ->
      state
      |> Map.get(:racers, [])
      |> Enum.map(&Map.take(&1, fields))
    end)
  end
end
