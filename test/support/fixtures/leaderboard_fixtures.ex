defmodule Leadfoot.LeaderboardFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Leadfoot.Leaderboard` context.
  """

  @doc """
  Generate a lap_time.
  """
  def lap_time_fixture(attrs \\ %{}) do
    {:ok, lap_time} =
      attrs
      |> Enum.into(%{
        car: "some car",
        input_method: "some input_method",
        lap_time_millis: 42,
        notes: "some notes",
        track: "some track",
        tune: "some tune",
        video_url: "some video_url"
      })
      |> Leadfoot.Leaderboard.create_lap_time()

    lap_time
  end
end
