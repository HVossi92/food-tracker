defmodule FoodTrackerWeb.PageControllerTest do
  use FoodTrackerWeb.ConnCase

  test "GET /", %{conn: conn} do
    # The "/" path now redirects to login, this is expected
    conn = get(conn, ~p"/")
    assert redirected_to(conn) == ~p"/users/log_in"
  end
end
