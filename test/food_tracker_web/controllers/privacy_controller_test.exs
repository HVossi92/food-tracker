defmodule FoodTrackerWeb.PrivacyControllerTest do
  use FoodTrackerWeb.ConnCase

  test "GET /privacy shows privacy policy with anonymous user information", %{conn: conn} do
    conn = get(conn, ~p"/privacy")

    # Check that the page loads successfully
    assert html_response(conn, 200) =~ "Privacy Policy"

    # Check for anonymous user related content
    assert html_response(conn, 200) =~ "Anonymous Users"
    assert html_response(conn, 200) =~ "Anonymous identifiers"

    assert html_response(conn, 200) =~
             "Anonymous user accounts are automatically deleted after 30 days"

    assert html_response(conn, 200) =~ "When you convert to a registered account"
  end
end
