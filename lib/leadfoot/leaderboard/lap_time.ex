defmodule Leadfoot.Leaderboard.LapTime do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "lap_times" do
    field :car, :string
    field :input_method, :string
    field :lap_time_millis, :integer
    field :notes, :string
    field :track, :string
    field :tune, :string
    field :video_url, :string
    field :user_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(lap_time, attrs) do
    lap_time
    |> cast(attrs, [:lap_time_millis, :car, :track, :tune, :input_method, :video_url, :notes])
    |> validate_required([:lap_time_millis, :car, :track, :tune, :input_method, :video_url, :notes])
  end
end
