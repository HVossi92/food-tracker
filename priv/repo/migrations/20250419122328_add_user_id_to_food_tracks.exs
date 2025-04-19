defmodule FoodTracker.Repo.Migrations.AddUserIdToFoodTracks do
  use Ecto.Migration

  def change do
    alter table(:food_tracks) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
    end

    create index(:food_tracks, [:user_id])
  end
end
