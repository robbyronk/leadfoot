defmodule Leadfoot.Repo do
  use Ecto.Repo,
    otp_app: :leadfoot,
    adapter: Ecto.Adapters.Postgres
end
