defmodule AiEmailSorting.Repo.Migrations.AddUserToCategories do
  use Ecto.Migration

  def change do
    alter table(:categories) do
      add :user_id, references(:users, on_delete: :nothing)
    end
  end
end
