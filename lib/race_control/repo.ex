defmodule RaceControl.Repo do
  use Ecto.Repo,
    otp_app: :race_control,
    adapter: Ecto.Adapters.Postgres
end
