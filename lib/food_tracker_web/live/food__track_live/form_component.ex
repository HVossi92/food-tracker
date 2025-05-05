defmodule FoodTrackerWeb.Food_TrackLive.FormComponent do
  use FoodTrackerWeb, :live_component

  alias FoodTracker.Food_Tracking
  alias FoodTracker.Accounts

  @impl true
  def render(assigns) do
    assigns = assign_new(assigns, :subtitle, fn -> nil end)

    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle :if={@subtitle}>{@subtitle}</:subtitle>
      </.header>

      <%!-- Display date value properly: --%>

      <.simple_form
        for={@form}
        id="food__track-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:date]} type="date" label="Date" />
        <.input field={@form[:time]} type="time" label="Time" />
        <.input
          phx-hook="LocalTime"
          id="form-time-input"
          field={@form[:time]}
          type="time"
          label="Time"
        />
        <:actions>
          <.button phx-disable-with="Saving...">Save Food Log</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{food__track: food__track} = assigns, socket) do
    # Get the user ID for ownership verification
    user_id = get_user_id(assigns)

    # For new food tracks, use the simple changeset
    # For existing food tracks, verify ownership using the improved function
    changeset =
      if food__track.id do
        # Get the food track with ownership verification
        Food_Tracking.change_food__track_with_user(food__track.id, user_id)
      else
        # For new food tracks, create a changeset
        Food_Tracking.Food_Track.changeset(food__track, %{})
      end

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"food__track" => food__track_params}, socket) do
    changeset =
      socket.assigns.food__track
      |> Food_Tracking.Food_Track.changeset(food__track_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"food__track" => food__track_params}, socket) do
    save_food__track(socket, socket.assigns.action, food__track_params)
  end

  defp save_food__track(socket, :edit, food__track_params) do
    # Get the user ID for ownership verification
    user_id = get_user_id(socket.assigns)
    food_track_id = socket.assigns.food__track.id

    # Use the user-scoped update function that verifies ownership
    case Food_Tracking.update_food__track(food_track_id, user_id, food__track_params) do
      {:ok, food__track} ->
        notify_parent({:saved, food__track})

        {:noreply,
         socket
         |> put_flash(:info, "Food track updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_food__track(socket, :new, food__track_params) do
    {user_id, updated_socket} = ensure_user_exists(socket)

    # Get the user for limit checking
    user = socket.assigns[:current_user] || socket.assigns[:anonymous_user]

    # Check if user can add more food tracks today
    if FoodTracker.Food_Tracking.can_add_food_track?(user) do
      # Add user_id to the food track params
      food__track_params = Map.put(food__track_params, "user_id", user_id)

      case Food_Tracking.create_food__track(food__track_params) do
        {:ok, food__track} ->
          # Notify the parent LiveView about the saved food track
          notify_parent({:saved, food__track})

          {:noreply,
           updated_socket
           |> put_flash(:info, "Food track created successfully")
           |> push_patch(to: socket.assigns.patch)}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign_form(updated_socket, changeset)}
      end
    else
      # User has reached daily limit
      limit = FoodTracker.Food_Tracking.get_daily_food_track_limit(user)

      # Get the appropriate message based on account status
      message =
        if user && user.confirmed_at do
          "You've reached your daily limit of #{limit} food entries. This limit helps us control AI costs."
        else
          "You've reached your daily limit of #{limit} food entries. Create and confirm an account for higher limits."
        end

      {:noreply,
       updated_socket
       |> put_flash(:error, message)
       |> push_patch(to: socket.assigns.patch)}
    end
  end

  # Helper function to assign the form to the socket
  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  # Ensure a user exists (either current_user or anonymous_user)
  defp ensure_user_exists(socket) do
    cond do
      socket.assigns[:current_user] ->
        {socket.assigns.current_user.id, socket}

      socket.assigns[:anonymous_user] ->
        {socket.assigns.anonymous_user.id, socket}

      true ->
        # This is where a new food track is being created and we need to create an anonymous user
        anonymous_uuid = Ecto.UUID.generate()

        {:ok, anonymous_user} =
          Accounts.create_anonymous_user(%{
            anonymous_uuid: anonymous_uuid,
            is_anonymous: true,
            last_active_at: DateTime.utc_now() |> DateTime.truncate(:second)
          })

        # Store the anonymous user in the process dictionary so the parent can access it
        Process.put(:new_anonymous_user, anonymous_user)

        # Send event to set cookie in client
        token = %{
          "anonymous_uuid" => anonymous_uuid,
          "set_anonymous_cookie" => true
        }

        # Push event to parent LiveView to set the cookie
        send(self(), {:set_anonymous_cookie, token})

        # Also explicitly tell the parent to assign the anonymous user
        send(self(), {:assign_anonymous_user, anonymous_user})

        # Update socket with the new anonymous user
        socket = assign(socket, :anonymous_user, anonymous_user)

        {anonymous_user.id, socket}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  # Helper function to get user_id from assigns
  defp get_user_id(assigns) do
    cond do
      assigns[:current_user] ->
        assigns.current_user.id

      assigns[:anonymous_user] ->
        assigns.anonymous_user.id

      true ->
        nil
    end
  end
end
