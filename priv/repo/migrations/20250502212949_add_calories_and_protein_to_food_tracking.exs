defmodule FoodTracker.Repo.Migrations.AddCaloriesAndProteinToFoodTracking do
  use Ecto.Migration

  def change do
    alter table(:food_tracks) do
      add :calories, :string
      add :protein, :string
    end
  end
end
