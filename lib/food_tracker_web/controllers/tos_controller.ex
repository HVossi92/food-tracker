defmodule FoodTrackerWeb.TosController do
  use FoodTrackerWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end
end
