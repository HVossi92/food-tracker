defmodule FoodTrackerWeb.RootController do
  use FoodTrackerWeb, :controller

  def index(conn, _params) do
    if conn.assigns[:current_user] do
      redirect(conn, to: "/food_tracks")
    else
      redirect(conn, to: "/users/log_in")
    end
  end
end
