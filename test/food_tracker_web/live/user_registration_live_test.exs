defmodule FoodTrackerWeb.UserRegistrationLiveTest do
  use FoodTrackerWeb.ConnCase

  import Phoenix.LiveViewTest
  import FoodTracker.AccountsFixtures
  alias Phoenix.LiveView.Socket

  describe "Registration page" do
    test "renders registration page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/users/register")

      assert html =~ "Register"
      assert html =~ "Log in"
    end

    test "redirects if already logged in", %{conn: conn} do
      result =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/users/register")
        |> follow_redirect(conn, "/")

      assert {:ok, _conn} = result
    end

    test "Registration page renders errors for invalid data", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/register")

      result =
        lv
        |> form("#registration_form",
          user: %{email: "with spaces", password: "too"}
        )
        |> render_submit()

      assert result =~ "Register for an account"
      assert result =~ "must have the @ sign and no spaces"
      assert result =~ "should be at least 6 character"
    end
  end

  describe "register user" do
    test "creates account and logs the user in", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/register")

      email = unique_user_email()
      form = form(lv, "#registration_form", user: valid_user_attributes(email: email))
      render_submit(form)
      conn = follow_trigger_action(form, conn)

      assert redirected_to(conn) == ~p"/"

      # Now do a logged in request and assert on the menu
      conn = get(conn, "/")
      response = html_response(conn, 200)
      assert response =~ email
      assert response =~ "Settings"
      assert response =~ "Log out"
    end

    test "renders errors for duplicated email", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/register")

      user = user_fixture(%{email: "test@email.com"})

      result =
        lv
        |> form("#registration_form",
          user: %{"email" => user.email, "password" => "valid_password"}
        )
        |> render_submit()

      assert result =~ "has already been taken"
    end

    test "verifies data persistence in anonymous to registered conversion" do
      # Create an anonymous user
      anonymous_uuid = Ecto.UUID.generate()

      {:ok, anonymous_user} =
        FoodTracker.Accounts.create_anonymous_user(%{
          anonymous_uuid: anonymous_uuid,
          is_anonymous: true,
          last_active_at: DateTime.utc_now() |> DateTime.truncate(:second)
        })

      # Add some food tracks for this anonymous user
      {:ok, food_track} =
        FoodTracker.Food_Tracking.create_food__track(%{
          "name" => "Anonymous Breakfast",
          "date" => "2025-01-01",
          "time" => "08:30",
          "user_id" => anonymous_user.id
        })

      # Convert the anonymous user to a registered user
      email = unique_user_email()
      password = valid_user_password()

      {:ok, registered_user} =
        FoodTracker.Accounts.convert_anonymous_to_registered(
          anonymous_user,
          %{email: email, password: password}
        )

      # Verify the user is now registered with the same ID
      assert registered_user.id == anonymous_user.id
      assert registered_user.is_anonymous == false
      assert registered_user.email == email

      # Verify the food track is still accessible and linked to the same user
      retrieved_track = FoodTracker.Food_Tracking.get_food__track!(food_track.id)
      assert retrieved_track.name == "Anonymous Breakfast"
      assert retrieved_track.user_id == registered_user.id
    end
  end

  describe "registration navigation" do
    test "redirects to login page when the Log in button is clicked", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/register")

      {:ok, _login_live, login_html} =
        lv
        |> element(~s|main a:fl-contains("Log in")|)
        |> render_click()
        |> follow_redirect(conn, ~p"/users/log_in")

      assert login_html =~ "Log in"
    end
  end
end
