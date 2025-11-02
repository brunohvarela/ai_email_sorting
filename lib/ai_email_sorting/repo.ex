defmodule AiEmailSorting.Repo do
  use Ecto.Repo,
    otp_app: :ai_email_sorting,
    adapter: Ecto.Adapters.SQLite3
end
