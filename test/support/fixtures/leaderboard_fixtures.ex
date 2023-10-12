defmodule Leadfoot.LeaderboardFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Leadfoot.Leaderboard` context.
  """

  alias Leadfoot.AccountsFixtures

  @doc """
  Generate a lap_time.
  """
  def lap_time_fixture(attrs \\ %{}) do
    user = AccountsFixtures.user_fixture()

    attrs =
      Enum.into(attrs, %{
        car: "some car",
        input_method: "some input_method",
        lap_time_millis: 42,
        notes: "some notes",
        track: "some track",
        tune: "some tune",
        video_url: "some video_url"
      })

    {:ok, lap_time} = Leadfoot.Leaderboard.create_lap_time(user, attrs)

    lap_time
  end
end
