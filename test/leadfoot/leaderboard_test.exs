defmodule Leadfoot.LeaderboardTest do
  use Leadfoot.DataCase

  alias Leadfoot.AccountsFixtures
  alias Leadfoot.Leaderboard

  describe "lap_times" do
    import Leadfoot.LeaderboardFixtures

    alias Leadfoot.Leaderboard.LapTime

    @invalid_attrs %{car: nil, input_method: nil, lap_time_millis: nil, notes: nil, track: nil, tune: nil, video_url: nil}

    test "list_lap_times/0 returns all lap_times" do
      lap_time = lap_time_fixture()
      assert Leaderboard.list_lap_times() == [lap_time]
    end

    test "get_lap_time!/1 returns the lap_time with given id" do
      lap_time = lap_time_fixture()
      assert Leaderboard.get_lap_time!(lap_time.id) == lap_time
    end

    test "create_lap_time/1 with valid data creates a lap_time" do
      user = AccountsFixtures.user_fixture()

      valid_attrs = %{
        car: "some car",
        input_method: "some input_method",
        lap_time_millis: 42,
        notes: "some notes",
        track: "some track",
        tune: "some tune",
        video_url: "some video_url"
      }

      assert {:ok, %LapTime{} = lap_time} = Leaderboard.create_lap_time(user, valid_attrs)
      assert lap_time.car == "some car"
      assert lap_time.input_method == "some input_method"
      assert lap_time.lap_time_millis == 42
      assert lap_time.notes == "some notes"
      assert lap_time.track == "some track"
      assert lap_time.tune == "some tune"
      assert lap_time.video_url == "some video_url"
    end

    test "create_lap_time/1 with invalid data returns error changeset" do
      user = AccountsFixtures.user_fixture()

      assert {:error, %Ecto.Changeset{}} = Leaderboard.create_lap_time(user, @invalid_attrs)
    end

    test "update_lap_time/2 with valid data updates the lap_time" do
      lap_time = lap_time_fixture()

      update_attrs = %{
        car: "some updated car",
        input_method: "some updated input_method",
        lap_time_millis: 43,
        notes: "some updated notes",
        track: "some updated track",
        tune: "some updated tune",
        video_url: "some updated video_url"
      }

      assert {:ok, %LapTime{} = lap_time} = Leaderboard.update_lap_time(lap_time, update_attrs)
      assert lap_time.car == "some updated car"
      assert lap_time.input_method == "some updated input_method"
      assert lap_time.lap_time_millis == 43
      assert lap_time.notes == "some updated notes"
      assert lap_time.track == "some updated track"
      assert lap_time.tune == "some updated tune"
      assert lap_time.video_url == "some updated video_url"
    end

    test "update_lap_time/2 with invalid data returns error changeset" do
      lap_time = lap_time_fixture()
      assert {:error, %Ecto.Changeset{}} = Leaderboard.update_lap_time(lap_time, @invalid_attrs)
      assert lap_time == Leaderboard.get_lap_time!(lap_time.id)
    end

    test "delete_lap_time/1 deletes the lap_time" do
      lap_time = lap_time_fixture()
      assert {:ok, %LapTime{}} = Leaderboard.delete_lap_time(lap_time)
      assert_raise Ecto.NoResultsError, fn -> Leaderboard.get_lap_time!(lap_time.id) end
    end

    test "change_lap_time/1 returns a lap_time changeset" do
      lap_time = lap_time_fixture()
      assert %Ecto.Changeset{} = Leaderboard.change_lap_time(lap_time)
    end
  end
end
