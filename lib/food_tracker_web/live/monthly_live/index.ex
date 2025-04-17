defmodule FoodTrackerWeb.MonthlyLive.Index do
  use FoodTrackerWeb, :live_view

  alias FoodTracker.Food_Tracking
  alias FoodTracker.Food_Tracking.Food_Track
  alias FoodTracker.Utils

  @impl true
  def mount(_params, _session, socket) do
    today = Date.utc_today()
    current_month = %{month: today.month, year: today.year}

    socket =
      socket
      |> assign(:food__track, %Food_Track{})
      |> assign(:current_month, current_month)
      |> assign(:today, today)
      |> assign(:month_name, month_name(current_month.month))
      |> assign(:food_tracks, get_month_food_tracks(current_month.month, current_month.year))

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Food track")
    |> assign(:food__track, Food_Tracking.get_food__track!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Food track")
    |> assign(:food__track, %Food_Track{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Monthly Food Tracking")
  end

  @impl true
  def handle_info({FoodTrackerWeb.Food_TrackLive.FormComponent, {:saved, food__track}}, socket) do
    {:noreply, update_food_tracks(socket)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    food__track = Food_Tracking.get_food__track!(id)
    {:ok, _} = Food_Tracking.delete_food__track(food__track)

    {:noreply, update_food_tracks(socket)}
  end

  def handle_event("previous_month", _, socket) do
    current_month = socket.assigns.current_month
    {year, month} = previous_month(current_month.month, current_month.year)

    socket =
      socket
      |> assign(:current_month, %{month: month, year: year})
      |> assign(:month_name, month_name(month))
      |> assign(:food_tracks, get_month_food_tracks(month, year))

    {:noreply, socket}
  end

  def handle_event("next_month", _, socket) do
    current_month = socket.assigns.current_month
    {year, month} = next_month(current_month.month, current_month.year)

    socket =
      socket
      |> assign(:current_month, %{month: month, year: year})
      |> assign(:month_name, month_name(month))
      |> assign(:food_tracks, get_month_food_tracks(month, year))

    {:noreply, socket}
  end

  def handle_event("jump_to_today", _, socket) do
    today = Date.utc_today()

    if today.month == socket.assigns.current_month.month &&
         today.year == socket.assigns.current_month.year do
      # Already on the current month, do nothing
      {:noreply, socket}
    else
      socket =
        socket
        |> assign(:current_month, %{month: today.month, year: today.year})
        |> assign(:month_name, month_name(today.month))
        |> assign(:food_tracks, get_month_food_tracks(today.month, today.year))

      {:noreply, socket}
    end
  end

  defp update_food_tracks(socket) do
    current_month = socket.assigns.current_month
    assign(socket, :food_tracks, get_month_food_tracks(current_month.month, current_month.year))
  end

  defp get_month_food_tracks(month, year) do
    start_date = Date.new!(year, month, 1)
    end_date = Date.end_of_month(start_date)

    date_range = Date.range(start_date, end_date)

    # Group food tracks by date
    date_range
    |> Enum.reduce(%{}, fn date, acc ->
      date_string = Utils.date_to_ymd_string(date)
      tracks = Food_Tracking.list_food_tracks_on(date_string)
      Map.put(acc, date.day, tracks)
    end)
  end

  defp previous_month(1, year), do: {year - 1, 12}
  defp previous_month(month, year), do: {year, month - 1}

  defp next_month(12, year), do: {year + 1, 1}
  defp next_month(month, year), do: {year, month + 1}

  defp month_name(1), do: "January"
  defp month_name(2), do: "February"
  defp month_name(3), do: "March"
  defp month_name(4), do: "April"
  defp month_name(5), do: "May"
  defp month_name(6), do: "June"
  defp month_name(7), do: "July"
  defp month_name(8), do: "August"
  defp month_name(9), do: "September"
  defp month_name(10), do: "October"
  defp month_name(11), do: "November"
  defp month_name(12), do: "December"
end
