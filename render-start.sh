# Custom tasks (like DB migrations)
MIX_ENV=prod mix ecto.migrate

# Finally run the server
PORT=4001 MIX_ENV=prod mix phx.server