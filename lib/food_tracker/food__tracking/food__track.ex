defmodule FoodTracker.Food_Tracking.Food_Track do
  use Ecto.Schema
  import Ecto.Changeset

  schema "food_tracks" do
    field :name, :string
    field :date, :string
    field :time, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(food__track, attrs) do
    food__track
    |> cast(attrs, [:name, :date, :time])
    |> validate_required([:name, :date, :time])
    |> validate_format(:time, ~r/^([01]?[0-9]|2[0-3]):[0-5][0-9]$/,
      message: "must be in format HH:MM (e.g., 12:30)"
    )
    |> validate_format(:date, ~r/^\d{4}-(?:0[1-9]|1[0-2])-(?:0[1-9]|[12]\d|3[01])$/,
      message: "must be in format YYYY-MM-DD (e.g., 2025-04-15)"
    )
  end
end
