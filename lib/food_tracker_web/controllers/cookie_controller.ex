defmodule FoodTrackerWeb.CookieController do
  use FoodTrackerWeb, :controller
  alias FoodTracker.Accounts

  # Set anonymous cookie to be valid for 30 days
  @max_age 60 * 60 * 24 * 30
  @anonymous_cookie "_food_tracker_anonymous_uuid"
  @anonymous_cookie_options [sign: true, max_age: @max_age, same_site: "Lax"]

  def set_anonymous_cookie(conn, %{"uuid" => uuid, "return_to" => return_to}) do
    # Get or create the anonymous user
    {:ok, anonymous_user} = Accounts.get_or_create_anonymous_user(uuid)

    # Set the cookie and redirect back to the original page
    conn
    |> put_resp_cookie(@anonymous_cookie, uuid, @anonymous_cookie_options)
    |> put_session("anonymous_uuid", uuid)
    |> redirect(to: return_to)
  end
end
