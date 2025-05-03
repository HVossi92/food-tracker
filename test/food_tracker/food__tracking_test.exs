defmodule FoodTracker.Food_TrackingTest do
  use FoodTracker.DataCase

  alias FoodTracker.Food_Tracking
  alias FoodTracker.Accounts

  describe "food_tracks" do
    alias FoodTracker.Food_Tracking.Food_Track

    import FoodTracker.Food_TrackingFixtures
    import FoodTracker.AccountsFixtures

    @invalid_attrs %{"name" => nil, "date" => nil, "time" => nil, "user_id" => nil}

    setup do
      user = user_fixture()
      %{user: user}
    end

    test "list_food_tracks/1 returns all food_tracks for a user", %{user: user} do
      food__track = food__track_fixture(user: user)

      # Since list_food_tracks transforms date format, we need to get a new copy of the food_track
      result = Food_Tracking.list_food_tracks(user.id)

      # Compare IDs to verify the correct food track is returned
      assert length(result) == 1
      assert hd(result).id == food__track.id
      assert hd(result).name == food__track.name
      assert hd(result).time == food__track.time
      assert hd(result).user_id == food__track.user_id
    end

    test "get_food__track!/1 returns the food__track with given id", %{user: user} do
      food__track = food__track_fixture(user: user)
      assert Food_Tracking.get_food__track!(food__track.id) == food__track
    end

    test "create_food__track/1 with valid data creates a food__track", %{user: user} do
      valid_attrs = %{
        "name" => "some name",
        "date" => "2025-01-01",
        "time" => "12:30",
        "user_id" => user.id
      }

      assert {:ok, %Food_Track{} = food__track} = Food_Tracking.create_food__track(valid_attrs)
      assert food__track.name == "some name"
      assert food__track.date == "2025-01-01"
      assert food__track.time == "12:30"
      assert food__track.user_id == user.id
    end

    test "create_food__track/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Food_Tracking.create_food__track(@invalid_attrs)
    end

    test "update_food__track/2 with valid data updates the food__track", %{user: user} do
      food__track = food__track_fixture(user: user)

      update_attrs = %{
        "name" => "some updated name",
        "date" => "2025-01-02",
        "time" => "15:45"
      }

      assert {:ok, %Food_Track{} = food__track} =
               Food_Tracking.update_food__track(food__track, update_attrs)

      assert food__track.name == "some updated name"
      assert food__track.date == "2025-01-02"
      assert food__track.time == "15:45"
      assert food__track.user_id == user.id
    end

    test "update_food__track/2 with invalid data returns error changeset", %{user: user} do
      food__track = food__track_fixture(user: user)

      assert {:error, %Ecto.Changeset{}} =
               Food_Tracking.update_food__track(food__track, @invalid_attrs)

      assert food__track == Food_Tracking.get_food__track!(food__track.id)
    end

    test "delete_food__track/1 deletes the food__track", %{user: user} do
      food__track = food__track_fixture(user: user)
      assert {:ok, %Food_Track{}} = Food_Tracking.delete_food__track(food__track)
      assert_raise Ecto.NoResultsError, fn -> Food_Tracking.get_food__track!(food__track.id) end
    end

    test "change_food__track/1 returns a food__track changeset", %{user: user} do
      food__track = food__track_fixture(user: user)
      assert %Ecto.Changeset{} = Food_Tracking.change_food__track(food__track)
    end

    test "list_food_tracks_on/2 returns food tracks for a specific date and user", %{user: user} do
      # Create a food track for today
      today = Date.utc_today() |> Date.to_string()
      today_attrs = %{"name" => "Today's meal", "date" => today, "user_id" => user.id}
      {:ok, today_food_track} = Food_Tracking.create_food__track(today_attrs)

      # Create a food track for yesterday
      yesterday = Date.utc_today() |> Date.add(-1) |> Date.to_string()
      yesterday_attrs = %{"name" => "Yesterday's meal", "date" => yesterday, "user_id" => user.id}
      {:ok, _} = Food_Tracking.create_food__track(yesterday_attrs)

      # Get today's food tracks
      result = Food_Tracking.list_food_tracks_on(today, user.id)

      assert Map.has_key?(result, :food_tracks)
      assert length(result.food_tracks) == 1
      assert hd(result.food_tracks).id == today_food_track.id
      assert hd(result.food_tracks).name == "Today's meal"
    end
  end
end
