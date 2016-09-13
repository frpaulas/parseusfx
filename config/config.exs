# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :worldenglishbible,
  ecto_repos: [Worldenglishbible.Repo]

# Configures the endpoint
config :worldenglishbible, Worldenglishbible.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "4Ijo1DQkIHFlvR5SFKWdpM5l+zKT7XLKoJrdo2L39pZagBOT1BgRskLjWNE6iAvd",
  render_errors: [view: Worldenglishbible.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Worldenglishbible.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :mix_test_watch,
  clear: true

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
