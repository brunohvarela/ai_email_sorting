defmodule AiEmailSorting.Repo.Migrations.CreateEmailSummaries do
  use Ecto.Migration

  def change do
    create table(:email_summaries) do
      add :from, :string, null: false
      add :subject, :string, null: false
      add :summary, :string, null: false
      add :category_id, references(:categories, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:email_summaries, [:category_id])
  end
end
