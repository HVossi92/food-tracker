defmodule FoodTrackerWeb.AnonymousAuthTest do
  use FoodTrackerWeb.ConnCase, async: true

  import FoodTracker.AccountsFixtures
  import Phoenix.LiveViewTest

  alias FoodTracker.Accounts
  alias FoodTrackerWeb.AnonymousAuth

  describe "anonymous authentication" do
    test "redirects to public pages without anonymous user", %{conn: conn} do
      # Test home page without anonymous user
      conn = get(conn, "/")

      # Should still be accessible, should create anonymous user
      assert html_response(conn, 200)

      # Test monthly view without anonymous user
      conn = get(conn, "/monthly")

      # Should still be accessible, should create anonymous user
      assert html_response(conn, 200)
    end

    test "handles expired anonymous sessions", %{conn: conn} do
      # Create an anonymous user with old timestamp
      anonymous_user = anonymous_user_fixture()

      # Set last_active_at to 31 days ago (past the 30-day threshold)
      old_timestamp =
        DateTime.utc_now()
        |> DateTime.add(-31 * 24 * 60 * 60, :second)
        |> DateTime.truncate(:second)

      {:ok, anonymous_user} =
        anonymous_user
        |> Accounts.User.last_active_changeset(%{last_active_at: old_timestamp})
        |> FoodTracker.Repo.update()

      # Run the cleanup job
      Accounts.delete_inactive_anonymous_users(30)

      # Verify the user is deleted
      assert_raise Ecto.NoResultsError, fn ->
        FoodTracker.Repo.get!(Accounts.User, anonymous_user.id)
      end
    end

    test "preserves anonymous user during login", %{conn: conn} do
      # Create an anonymous user
      anonymous_user = anonymous_user_fixture()

      # Add some food tracks
      {:ok, food_track} =
        FoodTracker.Food_Tracking.create_food__track(%{
          "name" => "Pre-login Snack",
          "date" => "2025-01-01",
          "time" => "15:30",
          "user_id" => anonymous_user.id
        })

      # Create a regular user
      user = user_fixture()

      # Log in directly
      conn = log_in_user(conn, user)

      # Verify we're now logged in as the regular user
      assert get_session(conn, :user_token)

      # Anonymous user and their data should still exist in the database
      assert FoodTracker.Repo.get(Accounts.User, anonymous_user.id)
      assert FoodTracker.Food_Tracking.get_food__track!(food_track.id)
    end
  end
end
