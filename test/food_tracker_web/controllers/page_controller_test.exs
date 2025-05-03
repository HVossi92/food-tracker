defmodule FoodTrackerWeb.PageControllerTest do
  use FoodTrackerWeb.ConnCase

  test "GET /", %{conn: conn} do
    # With anonymous auth, the "/" path should no longer redirect to login
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Daily Food Tracker"
  end
end
