defmodule FoodTrackerWeb.UserRegistrationLive do
  use FoodTrackerWeb, :live_view

  alias FoodTracker.Accounts
  alias FoodTracker.Accounts.User
  import FoodTrackerWeb.AnonymousAuth, only: [convert_anonymous_to_registered: 2]

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Register for an account
        <:subtitle>
          <%= if @anonymous_user do %>
            You're currently using Munch Metrics as a guest.<br />
            Register to save your data permanently.
          <% else %>
            Already registered?
            <.link navigate={~p"/users/log_in"} class="font-semibold text-brand hover:underline">
              Log in
            </.link>
            to your account now.
          <% end %>
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="registration_form"
        phx-submit="save"
        phx-change="validate"
        phx-trigger-action={@trigger_submit}
        action={~p"/users/log_in?_action=registered"}
        method="post"
      >
        <.error :if={@check_errors}>
          Oops, something went wrong! Please check the errors below.
        </.error>

        <.input field={@form[:email]} type="email" label="Email" required />
        <.input field={@form[:password]} type="password" label="Password" required />

        <:actions>
          <%= if @anonymous_user do %>
            <.button phx-disable-with="Converting account..." class="w-full">
              Convert to full account
            </.button>
          <% else %>
            <.button phx-disable-with="Creating account..." class="w-full">
              Create an account
            </.button>
          <% end %>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{})

    # Check if we have an anonymous user to convert
    has_anonymous_user =
      Map.has_key?(socket.assigns, :anonymous_user) && socket.assigns.anonymous_user

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign(anonymous_user: has_anonymous_user)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    # If we have an anonymous user, convert it to a registered user
    if socket.assigns.anonymous_user do
      handle_anonymous_conversion(socket, user_params)
    else
      # Normal registration flow
      handle_normal_registration(socket, user_params)
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp handle_anonymous_conversion(socket, user_params) do
    case convert_anonymous_to_registered(socket.conn, user_params) do
      {:ok, conn, user} ->
        # Send confirmation instructions
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        changeset = Accounts.change_user_registration(user)

        {:noreply,
         socket
         |> assign(trigger_submit: true)
         |> assign_form(changeset)}

      {:error, changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  defp handle_normal_registration(socket, user_params) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        changeset = Accounts.change_user_registration(user)
        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
