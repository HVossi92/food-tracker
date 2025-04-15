defmodule FoodTracker.Repo do
  use Ecto.Repo,
    otp_app: :food_tracker,
    adapter: Ecto.Adapters.SQLite3
end
