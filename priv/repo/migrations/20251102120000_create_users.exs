defmodule AiEmailSorting.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :google_uid, :string, null: false
      add :email, :string, null: false
      add :name, :string
      add :given_name, :string
      add :family_name, :string
      add :avatar_url, :string
      add :locale, :string
      add :access_token, :string
      add :refresh_token, :string
      add :token_expires_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:google_uid])
    create unique_index(:users, [:email])
  end
end
