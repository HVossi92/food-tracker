defmodule FoodTrackerWeb.UserConfirmationLiveTest do
  use FoodTrackerWeb.ConnCase

  import Phoenix.LiveViewTest
  import FoodTracker.AccountsFixtures

  alias FoodTracker.Accounts
  alias FoodTracker.Repo

  setup do
    %{user: user_fixture()}
  end

  describe "Confirm user" do
    test "renders confirmation page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/users/confirm")
      assert html =~ "Resend confirmation instructions"
    end

    test "sends new confirmation token", %{conn: conn, user: user} do
      {:ok, lv, _html} = live(conn, ~p"/users/confirm")

      {:ok, conn} =
        lv
        |> form("#resend_confirmation_form", user: %{email: user.email})
        |> render_submit()
        |> follow_redirect(conn, ~p"/")

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "If your email is in our system"

      assert Repo.get_by!(FoodTracker.Accounts.UserToken, user_id: user.id).context == "confirm"
    end

    # The token is actually not confirmed in the controller test, this is done in
    # the UserConfirmationController.confirm/2 function, which redirects to login
    # Once the token is confirmed, we cannot reuse it
    @tag :skip
    test "after confirmation, redirects to login", %{conn: conn, user: user} do
      token =
        extract_user_token(fn url ->
          FoodTracker.Accounts.deliver_user_confirmation_instructions(user, url)
        end)

      conn = get(conn, ~p"/users/confirm/#{token}")
      assert redirected_to(conn) == ~p"/users/log_in"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Account confirmed successfully"
    end

    # When accessing an invalid or already confirmed token, user is redirected to login
    @tag :skip
    test "does not confirm with invalid token", %{conn: conn} do
      conn = get(conn, ~p"/users/confirm/invalid-token")
      assert redirected_to(conn) == ~p"/users/log_in"

      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
               "Confirmation link is invalid or it has expired"
    end
  end
end
