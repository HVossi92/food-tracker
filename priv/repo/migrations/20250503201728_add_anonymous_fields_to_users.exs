defmodule FoodTracker.Repo.Migrations.AddAnonymousFieldsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :anonymous_uuid, :string
      add :is_anonymous, :boolean, default: false, null: false
      add :last_active_at, :utc_datetime
    end

    create index(:users, [:anonymous_uuid])
    create index(:users, [:last_active_at])
  end
end
