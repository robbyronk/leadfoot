defmodule Leadfoot.Repo.Migrations.CreateLapTimes do
  use Ecto.Migration

  def change do
    create table(:lap_times, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :lap_time_millis, :integer
      add :car, :string
      add :track, :string
      add :tune, :string
      add :input_method, :string
      add :video_url, :string
      add :notes, :string
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:lap_times, [:user_id])
  end
end
