defmodule FoodTracker.FoodTracking.FoodTrack do
  use Ecto.Schema
  import Ecto.Changeset

  schema "food_tracks" do
    field :name, :string
    field :date, :string, default: Date.utc_today() |> Date.to_string()
    field :time, :string, default: Time.utc_now() |> Time.to_string() |> String.slice(0, 5)
    field :calories, :string, default: ""
    field :protein, :string, default: ""
    field :user_id, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(food_track, attrs) do
    food_track
    |> cast(attrs, [:name, :date, :time, :user_id, :calories, :protein])
    |> validate_required([:name, :date, :time, :user_id])
    |> validate_format(:time, ~r/^([01]?[0-9]|2[0-3]):[0-5][0-9]$/,
      message: "must be in format HH:MM (e.g., 12:30)"
    )
    |> validate_format(:date, ~r/^\d{4}-(?:0[1-9]|1[0-2])-(?:0[1-9]|[12]\d|3[01])$/,
      message: "must be in format YYYY-MM-DD (e.g., 2025-04-15)"
    )
  end
end
