# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :rmc, RmcWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "TByljNXH7N8xJN3ll4KoNGf09w48erV7vVjQ0I/d5SdV9Chfe2Lk7TvaolhULMxX",
  render_errors: [view: RmcWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Rmc.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
