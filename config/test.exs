import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :ai_email_sorting, AiEmailSorting.Repo,
  database: Path.expand("../ai_email_sorting_test.db", __DIR__),
  pool_size: 5,
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ai_email_sorting, AiEmailSortingWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "HZDxqZy9Jw1GrXnzx9lHOj/t5Rnpc+SRkwHoOcc2fC3kzxn6zHark2AdXe2C0QBU",
  server: false

# In test we don't send emails
config :ai_email_sorting, AiEmailSorting.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

config :ai_email_sorting, AiEmailSorting.GoogleOAuth,
  client_id: "test-client-id",
  client_secret: "test-client-secret",
  authorization_endpoint: "https://accounts.google.com/o/oauth2/v2/auth",
  token_endpoint: "https://oauth2.googleapis.com/token",
  userinfo_endpoint: "https://www.googleapis.com/oauth2/v3/userinfo"
