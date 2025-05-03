defmodule FoodTrackerWeb.TosControllerTest do
  use FoodTrackerWeb.ConnCase

  test "GET /tos shows terms of service with anonymous user information", %{conn: conn} do
    conn = get(conn, ~p"/tos")

    # Check that the page loads successfully
    assert html_response(conn, 200) =~ "Terms of Service"

    # Check for anonymous user related content
    assert html_response(conn, 200) =~ "When using the Service anonymously"

    assert html_response(conn, 200) =~
             "Your data will be retained for a maximum of 30 days of inactivity"

    assert html_response(conn, 200) =~ "For anonymous users, we additionally make no warranty"
    assert html_response(conn, 200) =~ "You can convert to a registered account at any time"
  end
end
