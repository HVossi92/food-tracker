defmodule FoodTrackerWeb.CookieController do
  use FoodTrackerWeb, :controller
  alias FoodTracker.Accounts

  # Set anonymous cookie to be valid for 30 days
  @max_age 60 * 60 * 24 * 30
  @anonymous_cookie "_food_tracker_anonymous_uuid"
  @anonymous_cookie_options [sign: true, max_age: @max_age, same_site: "Lax"]

  def set_anonymous_cookie(conn, %{"uuid" => uuid, "return_to" => return_to}) do
    # Only get the anonymous user if it exists
    anonymous_user = Accounts.get_anonymous_user_by_uuid(uuid)

    if anonymous_user do
      # Update the last active timestamp
      {:ok, _} = Accounts.update_user_last_active(anonymous_user)

      # Set the cookie and redirect back to the original page
      conn
      |> put_resp_cookie(@anonymous_cookie, uuid, @anonymous_cookie_options)
      |> put_session("anonymous_uuid", uuid)
      |> redirect(to: return_to)
    else
      # If anonymous user doesn't exist, just redirect without setting cookie
      redirect(conn, to: return_to)
    end
  end
end
