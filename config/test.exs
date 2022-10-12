import Config

config :leadfoot, :udp_ip, {127, 0, 0, 1}

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :leadfoot, Leadfoot.Repo,
  database: Path.expand("../leadfoot_test.db", Path.dirname(__ENV__.file)),
  pool_size: 5,
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :leadfoot, LeadfootWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "2dN7Y8RsjvtDPx++zJlwfQv44gLJ/pd3ZY6liR3pwszZ4mbtonH8/JORBX8EtoxM",
  server: false

# In test we don't send emails.
config :leadfoot, Leadfoot.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
