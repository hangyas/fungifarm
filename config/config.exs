# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of Mix.Config.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
use Mix.Config

config :fungifarm_web,
  generators: [context_app: :fungifarm]

# Configures the endpoint
config :fungifarm_web, FungifarmWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "RJLZsOpkp+WN9aJmbJaMtGcB3coiq7mNrgpnv2jB8Z9iue9C9C8t4qPdjA1y3meb",
  render_errors: [view: FungifarmWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: FungifarmWeb.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
    signing_salt: "Y7EM1G2/QaBJ4y6qRR2e/ai31+38XSVA"
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

config :chartkick, json_serializer: Jason
