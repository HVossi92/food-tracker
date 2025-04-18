defmodule FoodTrackerWeb.Food_TrackLive.FormComponent do
  use FoodTrackerWeb, :live_component

  alias FoodTracker.Food_Tracking

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
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
          <.button phx-disable-with="Saving...">Save Food  track</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{food__track: food__track} = assigns, socket) do
    # Handle nil values by providing a default empty struct
    food__track = food__track || %FoodTracker.Food_Tracking.Food_Track{}

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:form, to_form(Food_Tracking.change_food__track(food__track)))}
  end

  @impl true
  def handle_event("validate", %{"food__track" => food__track_params}, socket) do
    changeset = Food_Tracking.change_food__track(socket.assigns.food__track, food__track_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"food__track" => food__track_params}, socket) do
    save_food__track(socket, socket.assigns.action, food__track_params)
  end

  defp save_food__track(socket, :edit, food__track_params) do
    case Food_Tracking.update_food__track(socket.assigns.food__track, food__track_params) do
      {:ok, food__track} ->
        notify_parent({:saved, food__track})

        {:noreply,
         socket
         |> put_flash(:info, "Food  track updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_food__track(socket, :new, food__track_params) do
    case Food_Tracking.create_food__track(food__track_params) do
      {:ok, food__track} ->
        notify_parent({:saved, food__track})

        {:noreply,
         socket
         |> put_flash(:info, "Food  track created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
