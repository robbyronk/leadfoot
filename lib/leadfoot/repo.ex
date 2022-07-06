defmodule Leadfoot.Repo do
  use Ecto.Repo,
    otp_app: :leadfoot,
    adapter: Ecto.Adapters.SQLite3
end
