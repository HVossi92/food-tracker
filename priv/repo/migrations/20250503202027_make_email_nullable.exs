defmodule FoodTracker.Repo.Migrations.MakeEmailNullable do
  use Ecto.Migration

  def change do
    # Create a new table with the desired structure
    create table(:users_new) do
      add :email, :string, null: true
      add :hashed_password, :string, null: true
      add :confirmed_at, :utc_datetime
      add :anonymous_uuid, :string
      add :is_anonymous, :boolean, default: false, null: false
      add :last_active_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    # Copy data from existing users table to the new one
    execute """
    INSERT INTO users_new (id, email, hashed_password, confirmed_at, anonymous_uuid, is_anonymous, last_active_at, inserted_at, updated_at)
    SELECT id, email, hashed_password, confirmed_at, anonymous_uuid, is_anonymous, last_active_at, inserted_at, updated_at
    FROM users;
    """

    # Drop the original table
    drop table(:users)

    # Rename new table to users
    rename table(:users_new), to: table(:users)

    # Re-create indexes
    create index(:users, [:anonymous_uuid])
    create index(:users, [:last_active_at])
  end
end
