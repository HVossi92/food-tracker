defmodule FoodTracker.Food_TrackingTest do
  use FoodTracker.DataCase

  alias FoodTracker.Food_Tracking

  describe "food_tracks" do
    alias FoodTracker.Food_Tracking.Food_Track

    import FoodTracker.Food_TrackingFixtures

    @invalid_attrs %{name: nil, date: nil, time: nil}

    test "list_food_tracks/0 returns all food_tracks" do
      food__track = food__track_fixture()
      assert Food_Tracking.list_food_tracks() == [food__track]
    end

    test "get_food__track!/1 returns the food__track with given id" do
      food__track = food__track_fixture()
      assert Food_Tracking.get_food__track!(food__track.id) == food__track
    end

    test "create_food__track/1 with valid data creates a food__track" do
      valid_attrs = %{name: "some name", date: "some date", time: "some time"}

      assert {:ok, %Food_Track{} = food__track} = Food_Tracking.create_food__track(valid_attrs)
      assert food__track.name == "some name"
      assert food__track.date == "some date"
      assert food__track.time == "some time"
    end

    test "create_food__track/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Food_Tracking.create_food__track(@invalid_attrs)
    end

    test "update_food__track/2 with valid data updates the food__track" do
      food__track = food__track_fixture()
      update_attrs = %{name: "some updated name", date: "some updated date", time: "some updated time"}

      assert {:ok, %Food_Track{} = food__track} = Food_Tracking.update_food__track(food__track, update_attrs)
      assert food__track.name == "some updated name"
      assert food__track.date == "some updated date"
      assert food__track.time == "some updated time"
    end

    test "update_food__track/2 with invalid data returns error changeset" do
      food__track = food__track_fixture()
      assert {:error, %Ecto.Changeset{}} = Food_Tracking.update_food__track(food__track, @invalid_attrs)
      assert food__track == Food_Tracking.get_food__track!(food__track.id)
    end

    test "delete_food__track/1 deletes the food__track" do
      food__track = food__track_fixture()
      assert {:ok, %Food_Track{}} = Food_Tracking.delete_food__track(food__track)
      assert_raise Ecto.NoResultsError, fn -> Food_Tracking.get_food__track!(food__track.id) end
    end

    test "change_food__track/1 returns a food__track changeset" do
      food__track = food__track_fixture()
      assert %Ecto.Changeset{} = Food_Tracking.change_food__track(food__track)
    end
  end
end
