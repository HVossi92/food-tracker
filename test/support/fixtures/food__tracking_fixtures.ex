defmodule FoodTracker.Food_TrackingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `FoodTracker.Food_Tracking` context.
  """

  import FoodTracker.AccountsFixtures

  @doc """
  Generate a food__track.
  """
  def food__track_fixture(attrs \\ %{}) do
    # Create a test user if not provided in attrs
    attrs = if is_map(attrs), do: attrs, else: Map.new(attrs)
    user = Map.get(attrs, :user) || user_fixture()
    user_id = Map.get(attrs, :user_id) || user.id

    # Convert all attribute keys to strings and remove user related keys
    attrs =
      attrs
      |> Enum.reduce(%{}, fn {k, v}, acc ->
        if k in [:user, :user_id] do
          acc
        else
          Map.put(acc, to_string(k), v)
        end
      end)
      |> Map.put("user_id", user_id)

    {:ok, food__track} =
      attrs
      |> Enum.into(%{
        "date" => "2025-01-01",
        "name" => "some name",
        "time" => "12:30"
      })
      |> FoodTracker.Food_Tracking.create_food__track()

    food__track
  end
end
