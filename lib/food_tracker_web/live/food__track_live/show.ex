defmodule FoodTrackerWeb.Food_TrackLive.Show do
  use FoodTrackerWeb, :live_view

  alias FoodTracker.Food_Tracking

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    # Get the user ID from either the current user or anonymous user
    user_id = get_user_id(socket)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:food__track, Food_Tracking.get_food__track!(id, user_id))}
  end

  @impl true
  def handle_info({FoodTrackerWeb.Food_TrackLive.FormComponent, {:saved, food__track}}, socket) do
    {:noreply,
     socket
     |> assign(:food__track, food__track)
     |> put_flash(:info, "Food track updated successfully")}
  end

  @impl true
  def handle_info(
        {FoodTrackerWeb.Food_TrackLive.FormComponent_Extended, {:saved, food__track}},
        socket
      ) do
    handle_info({FoodTrackerWeb.Food_TrackLive.FormComponent, {:saved, food__track}}, socket)
  end

  defp page_title(:show), do: "Show Food  track"
  defp page_title(:edit), do: "Edit Food  track"

  # Get user ID from either current_user or anonymous_user
  defp get_user_id(socket) do
    cond do
      socket.assigns[:current_user] ->
        socket.assigns.current_user.id

      socket.assigns[:anonymous_user] ->
        socket.assigns.anonymous_user.id

      true ->
        nil
    end
  end
end
