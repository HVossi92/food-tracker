defmodule FoodTracker.Food_TrackingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `FoodTracker.Food_Tracking` context.
  """

  @doc """
  Generate a food__track.
  """
  def food__track_fixture(attrs \\ %{}) do
    {:ok, food__track} =
      attrs
      |> Enum.into(%{
        date: "some date",
        name: "some name",
        time: "some time"
      })
      |> FoodTracker.Food_Tracking.create_food__track()

    food__track
  end
end
