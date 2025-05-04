defmodule FoodTrackerWeb.AnonymousAuth do
  @moduledoc """
  Functions for handling anonymous user authentication.
  """
  import Plug.Conn
  import Phoenix.Controller
  alias FoodTracker.Accounts

  # Set anonymous cookie to be valid for 30 days
  @max_age 60 * 60 * 24 * 30
  @anonymous_cookie "_food_tracker_anonymous_uuid"
  @anonymous_cookie_options [sign: true, max_age: @max_age, same_site: "Lax"]

  @doc """
  Creates or retrieves an anonymous user based on the cookie.
  """
  def fetch_anonymous_user(conn, _opts) do
    # Only proceed if there's no authenticated user
    if is_nil(conn.assigns[:current_user]) do
      {anonymous_uuid, conn} = ensure_anonymous_uuid(conn)

      if anonymous_uuid do
        # Only get existing anonymous user, don't create a new one
        case Accounts.get_anonymous_user_by_uuid(anonymous_uuid) do
          %Accounts.User{} = anonymous_user ->
            # Update last active and store in session
            {:ok, anonymous_user} = Accounts.update_user_last_active(anonymous_user)
            # Store the anonymous_uuid in the session for LiveView
            conn = put_session(conn, "anonymous_uuid", anonymous_uuid)
            assign(conn, :anonymous_user, anonymous_user)

          nil ->
            # If UUID cookie exists but user doesn't, assign nil
            assign(conn, :anonymous_user, nil)
        end
      else
        assign(conn, :anonymous_user, nil)
      end
    else
      # If there's an authenticated user, ensure we update their last_active timestamp
      if conn.assigns[:current_user] do
        Accounts.update_user_last_active(conn.assigns[:current_user])
      end

      assign(conn, :anonymous_user, nil)
    end
  end

  @doc """
  Creates an anonymous user on first visit.
  Sets anonymous_uuid in a cookie.
  """
  def create_anonymous_user(conn, _opts) do
    # Only create if no current user and no anonymous user
    if is_nil(conn.assigns[:current_user]) && is_nil(conn.assigns[:anonymous_user]) do
      # Generate a new anonymous UUID
      anonymous_uuid = Ecto.UUID.generate()

      # Create an anonymous user
      {:ok, anonymous_user} =
        Accounts.create_anonymous_user(%{
          anonymous_uuid: anonymous_uuid,
          is_anonymous: true,
          last_active_at: DateTime.utc_now() |> DateTime.truncate(:second)
        })

      # Set the cookie and assign the user
      conn
      |> put_resp_cookie(@anonymous_cookie, anonymous_uuid, @anonymous_cookie_options)
      |> put_session("anonymous_uuid", anonymous_uuid)
      |> assign(:anonymous_user, anonymous_user)
    else
      conn
    end
  end

  @doc """
  Checks for the anonymous UUID in cookies.
  If present, returns the UUID and updates the conn to include it in the session.
  """
  defp ensure_anonymous_uuid(conn) do
    conn = fetch_cookies(conn, signed: [@anonymous_cookie])

    if anonymous_uuid = conn.cookies[@anonymous_cookie] do
      {anonymous_uuid, conn}
    else
      {nil, conn}
    end
  end

  @doc """
  Converts an anonymous user to a registered user.
  Transfers all data and maintains the same user ID.
  Called when an anonymous user registers an account.
  """
  def convert_anonymous_to_registered(conn, user_params) do
    anonymous_user = conn.assigns[:anonymous_user]

    if anonymous_user do
      case Accounts.convert_anonymous_to_registered(anonymous_user, user_params) do
        {:ok, registered_user} ->
          # Delete the anonymous cookie as it's no longer needed
          conn = delete_resp_cookie(conn, @anonymous_cookie)

          # Return the registered user
          {:ok, conn, registered_user}

        {:error, changeset} ->
          {:error, changeset}
      end
    else
      {:error, :no_anonymous_user}
    end
  end

  @doc """
  LiveView hook to assign anonymous user in LiveView socket
  """
  def on_mount(:mount_anonymous_user, _params, session, socket) do
    anonymous_uuid = session["anonymous_uuid"]

    socket =
      if anonymous_uuid && is_nil(socket.assigns[:current_user]) do
        case Accounts.get_or_create_anonymous_user(anonymous_uuid) do
          {:ok, anonymous_user} ->
            Phoenix.Component.assign(socket, :anonymous_user, anonymous_user)

          _ ->
            Phoenix.Component.assign(socket, :anonymous_user, nil)
        end
      else
        Phoenix.Component.assign(socket, :anonymous_user, nil)
      end

    {:cont, socket}
  end

  @doc """
  LiveView hook that ensures a user is either authenticated or anonymous
  """
  def on_mount(:ensure_authenticated_or_anonymous, _params, session, socket) do
    # First try to mount the current user using the public on_mount function from UserAuth
    {:cont, socket_with_user} =
      FoodTrackerWeb.UserAuth.on_mount(:mount_current_user, _params, session, socket)

    # Then mount anonymous user if needed
    socket = mount_anonymous_user(socket_with_user, session)

    # Allow access whether or not a user is present
    # We'll no longer create anonymous users at this stage
    {:cont, socket}
  end

  defp mount_anonymous_user(socket, session) do
    Phoenix.Component.assign_new(socket, :anonymous_user, fn ->
      if anonymous_uuid = session["anonymous_uuid"] do
        # Only get existing anonymous user, don't create
        Accounts.get_anonymous_user_by_uuid(anonymous_uuid)
      else
        nil
      end
    end)
  end
end
