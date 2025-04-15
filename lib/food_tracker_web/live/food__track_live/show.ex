defmodule FoodTrackerWeb.Food_TrackLive.Show do
  use FoodTrackerWeb, :live_view

  alias FoodTracker.Food_Tracking

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:food__track, Food_Tracking.get_food__track!(id))}
  end

  defp page_title(:show), do: "Show Food  track"
  defp page_title(:edit), do: "Edit Food  track"
end
