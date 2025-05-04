defmodule FoodTrackerWeb.Food_TrackLive.Index do
  use FoodTrackerWeb, :live_view

  alias FoodTracker.Food_Tracking
  alias FoodTracker.Food_Tracking.Food_Track
  alias FoodTracker.Utils

  @impl true
  def mount(_params, _session, socket) do
    today = Date.utc_today() |> Utils.date_to_dmy_string()
    today_ymd = Date.utc_today() |> Utils.date_to_ymd_string()

    # Get the user ID from either the current user or anonymous user
    user_id = get_user_id(socket)
    user = socket.assigns[:current_user] || socket.assigns[:anonymous_user]

    # Get today's usage and limit information
    todays_usage = Food_Tracking.count_todays_food_tracks(user_id)
    daily_limit = Food_Tracking.get_daily_food_track_limit(user)
    remaining_entries = max(0, daily_limit - todays_usage)

    socket =
      socket
      |> assign(:food__track, %FoodTracker.Food_Tracking.Food_Track{})
      |> assign(:date, today)
      |> assign(:today, today)
      |> assign(:todays_usage, todays_usage)
      |> assign(:daily_limit, daily_limit)
      |> assign(:remaining_entries, remaining_entries)

    # Pattern match the return value to get food_tracks, calories, and protein
    %{food_tracks: food_tracks, calories: total_calories, protein: total_protein} =
      Food_Tracking.list_food_tracks_on(today_ymd, user_id)

    socket =
      socket
      |> assign(:total_calories, total_calories)
      |> assign(:total_protein, total_protein)
      |> maybe_assign_anonymous_banner()

    {:ok, stream(socket, :food_tracks, food_tracks)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    user_id = get_user_id(socket)
    user = socket.assigns[:current_user] || socket.assigns[:anonymous_user]

    # Get today's usage and limit information
    todays_usage = Food_Tracking.count_todays_food_tracks(user_id)
    daily_limit = Food_Tracking.get_daily_food_track_limit(user)
    remaining_entries = max(0, daily_limit - todays_usage)

    socket =
      socket
      |> assign(:todays_usage, todays_usage)
      |> assign(:daily_limit, daily_limit)
      |> assign(:remaining_entries, remaining_entries)

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

          # Pattern match the return value to get food_tracks, calories, and protein
          %{food_tracks: food_tracks, calories: total_calories, protein: total_protein} =
            Food_Tracking.list_food_tracks_on(date_string, user_id)

          socket
          |> assign(:date, Utils.year_month_day_to_day_month_year(date_string))
          |> assign(:total_calories, total_calories)
          |> assign(:total_protein, total_protein)
          |> stream(:food_tracks, [], reset: true)
          |> stream(:food_tracks, food_tracks)

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
    # Get the current date from the UI and convert to YYYY-MM-DD format for the database
    current_date_dmy = socket.assigns.date

    current_date_ymd =
      FoodTracker.Utils.string_to_date(current_date_dmy)
      |> FoodTracker.Utils.date_to_ymd_string()

    socket
    |> assign(:page_title, "New Food track")
    |> assign(:food__track, %Food_Track{date: current_date_ymd})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Food tracks")
  end

  @impl true
  def handle_info({FoodTrackerWeb.Food_TrackLive.FormComponent, {:saved, food__track}}, socket) do
    # First ensure we have the latest anonymous_user from the component if it was just created
    socket =
      if is_nil(socket.assigns[:anonymous_user]) && socket.assigns[:current_user] == nil do
        # This likely means an anonymous user was just created in the form component
        # Get the anonymous_user from the process dictionary where the form component stored it
        new_anon_user = Process.get(:new_anonymous_user)

        if new_anon_user do
          # Clear it from process dictionary
          Process.put(:new_anonymous_user, nil)

          # Update the socket with the new anonymous user
          socket
          |> assign(:anonymous_user, new_anon_user)
          |> maybe_assign_anonymous_banner()
        else
          socket
        end
      else
        socket
      end

    # Now get the user ID (which will use the newly assigned anonymous user if one was created)
    user_id = get_user_id(socket)
    user = socket.assigns[:current_user] || socket.assigns[:anonymous_user]

    # Update usage information
    todays_usage = Food_Tracking.count_todays_food_tracks(user_id)
    daily_limit = Food_Tracking.get_daily_food_track_limit(user)
    remaining_entries = max(0, daily_limit - todays_usage)

    %{food_tracks: food_tracks, calories: total_calories, protein: total_protein} =
      Food_Tracking.list_food_tracks_on(food__track.date, user_id)

    socket =
      socket
      |> assign(:todays_usage, todays_usage)
      |> assign(:daily_limit, daily_limit)
      |> assign(:remaining_entries, remaining_entries)
      |> assign(:total_calories, total_calories)
      |> assign(:total_protein, total_protein)
      |> stream(:food_tracks, [], reset: true)
      |> stream(:food_tracks, food_tracks)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:set_anonymous_cookie, token}, socket) do
    # Forward the token to the client to set the cookie
    {:noreply, push_event(socket, "set-anonymous-cookie", token)}
  end

  @impl true
  def handle_info({:assign_anonymous_user, anonymous_user}, socket) do
    # Assign the anonymous user to the socket and update the banner
    socket =
      socket
      |> assign(:anonymous_user, anonymous_user)
      |> maybe_assign_anonymous_banner()

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    food__track = Food_Tracking.get_food__track!(id)
    {:ok, _} = Food_Tracking.delete_food__track(food__track)

    # After deleting, refresh the daily totals
    user_id = get_user_id(socket)
    user = socket.assigns[:current_user] || socket.assigns[:anonymous_user]

    # Update usage information
    todays_usage = Food_Tracking.count_todays_food_tracks(user_id)
    daily_limit = Food_Tracking.get_daily_food_track_limit(user)
    remaining_entries = max(0, daily_limit - todays_usage)

    current_date = socket.assigns.date
    date_ymd = FoodTracker.Utils.string_to_date(current_date) |> Utils.date_to_ymd_string()

    # Get updated totals
    %{food_tracks: _, calories: total_calories, protein: total_protein} =
      Food_Tracking.list_food_tracks_on(date_ymd, user_id)

    socket =
      socket
      |> assign(:todays_usage, todays_usage)
      |> assign(:daily_limit, daily_limit)
      |> assign(:remaining_entries, remaining_entries)
      |> assign(:total_calories, total_calories)
      |> assign(:total_protein, total_protein)
      |> stream_delete(:food_tracks, food__track)

    {:noreply, socket}
  end

  def handle_event("previous_day", _, socket) do
    user_id = get_user_id(socket)
    current_date = socket.assigns.date
    current_date = FoodTracker.Utils.string_to_date(current_date)
    new_date = Date.add(current_date, -1)
    new_date_string = Utils.date_to_ymd_string(new_date)

    # Pattern match the return value to get food_tracks, calories, and protein
    %{food_tracks: food_tracks, calories: total_calories, protein: total_protein} =
      Food_Tracking.list_food_tracks_on(new_date_string, user_id)

    socket =
      socket
      |> assign(:date, Utils.date_to_dmy_string(new_date))
      |> assign(:food__track, %FoodTracker.Food_Tracking.Food_Track{date: new_date_string})
      |> assign(:total_calories, total_calories)
      |> assign(:total_protein, total_protein)
      |> stream(:food_tracks, [], reset: true)
      |> stream(:food_tracks, food_tracks)

    {:noreply, socket}
  end

  def handle_event("today", _, socket) do
    user_id = get_user_id(socket)
    new_date = Date.utc_today()
    new_date_string = Utils.date_to_ymd_string(new_date)

    # Pattern match the return value to get food_tracks, calories, and protein
    %{food_tracks: food_tracks, calories: total_calories, protein: total_protein} =
      Food_Tracking.list_food_tracks_on(new_date_string, user_id)

    socket =
      socket
      |> assign(:date, Utils.date_to_dmy_string(new_date))
      |> assign(:food__track, %FoodTracker.Food_Tracking.Food_Track{date: new_date_string})
      |> assign(:total_calories, total_calories)
      |> assign(:total_protein, total_protein)
      |> stream(:food_tracks, [], reset: true)
      |> stream(:food_tracks, food_tracks)

    {:noreply, socket}
  end

  def handle_event("next_day", _, socket) do
    user_id = get_user_id(socket)
    current_date = socket.assigns.date
    current_date = FoodTracker.Utils.string_to_date(current_date)
    new_date = Date.add(current_date, 1)
    new_date_string = Utils.date_to_ymd_string(new_date)

    # Pattern match the return value to get food_tracks, calories, and protein
    %{food_tracks: food_tracks, calories: total_calories, protein: total_protein} =
      Food_Tracking.list_food_tracks_on(new_date_string, user_id)

    socket =
      socket
      |> assign(:date, Utils.date_to_dmy_string(new_date))
      |> assign(:food__track, %FoodTracker.Food_Tracking.Food_Track{date: new_date_string})
      |> assign(:total_calories, total_calories)
      |> assign(:total_protein, total_protein)
      |> stream(:food_tracks, [], reset: true)
      |> stream(:food_tracks, food_tracks)

    {:noreply, socket}
  end

  # Helper functions for anonymous user support

  # Get user ID from either current_user or anonymous_user
  defp get_user_id(socket) do
    cond do
      socket.assigns[:current_user] ->
        socket.assigns.current_user.id

      socket.assigns[:anonymous_user] ->
        socket.assigns.anonymous_user.id

      true ->
        # We don't create an anonymous user here anymore
        # Return nil to indicate no user exists yet
        nil
    end
  end

  # Add a banner for anonymous users
  defp maybe_assign_anonymous_banner(socket) do
    if socket.assigns[:anonymous_user] do
      assign(socket, :anonymous_banner, true)
    else
      assign(socket, :anonymous_banner, false)
    end
  end
end
