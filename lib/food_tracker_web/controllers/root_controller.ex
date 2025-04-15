defmodule FoodTrackerWeb.RootController do
  use FoodTrackerWeb, :controller

  def index(conn, _params) do
    redirect(conn, to: "/food_tracks")
  end
end
