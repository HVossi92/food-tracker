defmodule FoodTrackerWeb.Food_TrackLive.Index do
  use FoodTrackerWeb, :live_view

  alias FoodTracker.Food_Tracking
  alias FoodTracker.Food_Tracking.Food_Track

  @impl true
  def mount(_params, _session, socket) do
    socket = assign(socket, :food__track, %FoodTracker.Food_Tracking.Food_Track{})
    {:ok, stream(socket, :food_tracks, Food_Tracking.list_food_tracks())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Food  track")
    |> assign(:food__track, Food_Tracking.get_food__track!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Food  track")
    |> assign(:food__track, %Food_Track{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Food tracks")
  end

  @impl true
  def handle_info({FoodTrackerWeb.Food_TrackLive.FormComponent, {:saved, food__track}}, socket) do
    {:noreply, stream_insert(socket, :food_tracks, food__track)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    food__track = Food_Tracking.get_food__track!(id)
    {:ok, _} = Food_Tracking.delete_food__track(food__track)

    {:noreply, stream_delete(socket, :food_tracks, food__track)}
  end
end
