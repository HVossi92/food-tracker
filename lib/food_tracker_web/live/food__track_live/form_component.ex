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
        <:actions>
          <.button phx-disable-with="Saving...">Save Food Log</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{food__track: food__track} = assigns, socket) do
    changeset = Food_Tracking.change_food__track(food__track)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"food__track" => food__track_params}, socket) do
    changeset =
      socket.assigns.food__track
      |> Food_Tracking.change_food__track(food__track_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"food__track" => food__track_params}, socket) do
    save_food__track(socket, socket.assigns.action, food__track_params)
  end

  defp save_food__track(socket, :edit, food__track_params) do
    # Ensure user_id can't be changed during edits
    food__track_params =
      Map.put(food__track_params, "user_id", socket.assigns.food__track.user_id)

    case Food_Tracking.update_food__track(socket.assigns.food__track, food__track_params) do
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
    # If we don't have a current user or anonymous user yet, create an anonymous user
    {user_id, socket} = ensure_user_exists(socket)

    # Add the user's ID to the food track params
    food__track_params = Map.put(food__track_params, "user_id", user_id)

    case Food_Tracking.create_food__track(food__track_params) do
      {:ok, food__track} ->
        notify_parent({:saved, food__track})

        {:noreply,
         socket
         |> put_flash(:info, "Food track created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
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
        # Create a new anonymous user
        anonymous_uuid = Ecto.UUID.generate()

        {:ok, anonymous_user} =
          Accounts.create_anonymous_user(%{
            anonymous_uuid: anonymous_uuid,
            is_anonymous: true,
            last_active_at: DateTime.utc_now() |> DateTime.truncate(:second)
          })

        # Send event to set cookie in client
        token = %{
          "anonymous_uuid" => anonymous_uuid,
          "set_anonymous_cookie" => true
        }

        # Push event to parent LiveView to set the cookie
        send(self(), {:set_anonymous_cookie, token})

        # Update socket with the new anonymous user
        socket = assign(socket, :anonymous_user, anonymous_user)

        {anonymous_user.id, socket}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
