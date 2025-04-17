defmodule FoodTrackerWeb.Food_TrackLive.Index do
  use FoodTrackerWeb, :live_view

  alias FoodTracker.Food_Tracking
  alias FoodTracker.Food_Tracking.Food_Track
  alias FoodTracker.Utils

  @impl true
  def mount(_params, _session, socket) do
    today = Date.utc_today() |> Utils.date_to_dmy_string()

    socket =
      socket
      |> assign(:food__track, %FoodTracker.Food_Tracking.Food_Track{})
      |> assign(:date, today)
      |> assign(:today, today)

    {:ok, stream(socket, :food_tracks, Food_Tracking.list_food_tracks_on(today))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    socket =
      case params do
        %{"date" => date} ->
          # If a date is provided in URL params, update the view with that date
          date_string =
            if FoodTracker.Utils.is_valid_date_string?(date) do
              date
            else
              # Try converting from day.month.year format
              try do
                date = FoodTracker.Utils.string_to_date(date)
                Utils.date_to_ymd_string(date)
              rescue
                _ -> Date.utc_today() |> Utils.date_to_ymd_string()
              end
            end

          socket
          |> assign(:date, Utils.year_month_day_to_day_month_year(date_string))
          |> stream(:food_tracks, [], reset: true)
          |> stream(:food_tracks, Food_Tracking.list_food_tracks_on(date_string))

        _ ->
          socket
      end

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

  def handle_event("previous_day", _, socket) do
    current_date = socket.assigns.date
    current_date = FoodTracker.Utils.string_to_date(current_date)
    new_date = Date.add(current_date, -1)
    new_date_string = Utils.date_to_ymd_string(new_date)

    socket =
      socket
      |> assign(:date, Utils.date_to_dmy_string(new_date))
      |> stream(:food_tracks, [], reset: true)
      |> stream(:food_tracks, Food_Tracking.list_food_tracks_on(new_date_string))

    {:noreply, socket}
  end

  def handle_event("today", _, socket) do
    new_date = Date.utc_today()
    new_date_string = Utils.date_to_ymd_string(new_date)

    socket =
      socket
      |> assign(:date, Utils.date_to_dmy_string(new_date))
      |> stream(:food_tracks, [], reset: true)
      |> stream(:food_tracks, Food_Tracking.list_food_tracks_on(new_date_string))

    {:noreply, socket}
  end

  def handle_event("next_day", _, socket) do
    current_date = socket.assigns.date
    current_date = FoodTracker.Utils.string_to_date(current_date)
    new_date = Date.add(current_date, 1)
    new_date_string = Utils.date_to_ymd_string(new_date)

    socket =
      socket
      |> assign(:date, Utils.date_to_dmy_string(new_date))
      |> stream(:food_tracks, [], reset: true)
      |> stream(:food_tracks, Food_Tracking.list_food_tracks_on(new_date_string))

    {:noreply, socket}
  end
end
