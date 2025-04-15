defmodule FoodTracker.Repo.Migrations.CreateFoodTracks do
  use Ecto.Migration

  def change do
    create table(:food_tracks) do
      add :name, :string
      add :date, :string
      add :time, :string

      timestamps(type: :utc_datetime)
    end
  end
end
