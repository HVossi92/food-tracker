defmodule FoodTrackerWeb.MonthlyLiveTest do
  use FoodTrackerWeb.ConnCase

  import Phoenix.LiveViewTest
  import FoodTracker.Food_TrackingFixtures
  import FoodTracker.AccountsFixtures

  setup %{conn: conn} do
    user = user_fixture()
    # Create a food track directly using the context instead of the fixture
    today = Date.utc_today()
    today_str = Date.to_string(today)

    {:ok, food__track} =
      FoodTracker.Food_Tracking.create_food__track(%{
        "name" => "some name",
        "date" => today_str,
        "time" => "12:30",
        "user_id" => user.id
      })

    # Log in the user
    conn = log_in_user(conn, user)

    %{conn: conn, food__track: food__track, user: user, today: today}
  end

  describe "Monthly View" do
    test "displays monthly calendar", %{conn: conn, today: today} do
      {:ok, monthly_live, html} = live(conn, ~p"/monthly")

      # Test for page title
      assert html =~ "Monthly Food Tracking"

      # Test for current month and year
      assert html =~ "#{month_name(today.month)} #{today.year}"

      # Test that the calendar is displayed
      assert html =~ "Sunday"
      assert html =~ "Monday"
    end

    @tag :skip
    test "can navigate to previous and next month", %{conn: conn} do
      {:ok, monthly_live, _html} = live(conn, ~p"/monthly")

      # Go to previous month
      prev_result = monthly_live |> element("a", "Previous month") |> render_click()

      # Get current month and verify it's the previous month
      today = Date.utc_today()
      {prev_year, prev_month} = prev_month(today.month, today.year)
      assert prev_result =~ "#{month_name(prev_month)} #{prev_year}"

      # Go to next month (back to current)
      next_result = monthly_live |> element("a", "Next month") |> render_click()
      assert next_result =~ "#{month_name(today.month)} #{today.year}"

      # Go to next month (future)
      future_result = monthly_live |> element("a", "Next month") |> render_click()
      {next_year, next_month} = next_month(today.month, today.year)
      assert future_result =~ "#{month_name(next_month)} #{next_year}"
    end

    @tag :skip
    test "can jump to today from a different month", %{conn: conn} do
      {:ok, monthly_live, _html} = live(conn, ~p"/monthly")

      # Go to previous month
      monthly_live |> element("a", "Previous month") |> render_click()

      # Test jump to today button
      jump_result = monthly_live |> element("button", "Jump to Today") |> render_click()

      today = Date.utc_today()
      assert jump_result =~ "#{month_name(today.month)} #{today.year}"
    end

    @tag :skip
    test "shows food tracks in the calendar", %{conn: conn, food__track: food_track, today: today} do
      {:ok, monthly_live, html} = live(conn, ~p"/monthly")

      # Find the day cell with today's date
      today_str = Integer.to_string(today.day)
      assert html =~ food_track.name
    end
  end

  # Helper functions to match the implementation in MonthlyLive.Index
  defp prev_month(1, year), do: {year - 1, 12}
  defp prev_month(month, year), do: {year, month - 1}

  defp next_month(12, year), do: {year + 1, 1}
  defp next_month(month, year), do: {year, month + 1}

  defp month_name(1), do: "January"
  defp month_name(2), do: "February"
  defp month_name(3), do: "March"
  defp month_name(4), do: "April"
  defp month_name(5), do: "May"
  defp month_name(6), do: "June"
  defp month_name(7), do: "July"
  defp month_name(8), do: "August"
  defp month_name(9), do: "September"
  defp month_name(10), do: "October"
  defp month_name(11), do: "November"
  defp month_name(12), do: "December"
end
