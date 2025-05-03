defmodule FoodTracker.Scheduler do
  @moduledoc """
  Handles scheduling of recurring tasks such as cleanup of inactive anonymous users.
  """
  use GenServer
  alias FoodTracker.Accounts
  require Logger

  # 24 hours in milliseconds
  @cleanup_interval 24 * 60 * 60 * 1000

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{})
  end

  @impl true
  def init(state) do
    schedule_cleanup()
    {:ok, state}
  end

  @impl true
  def handle_info(:cleanup_anonymous_users, state) do
    Logger.info("Running scheduled cleanup of inactive anonymous users")

    # Delete anonymous users inactive for more than 30 days
    {count, _} = Accounts.delete_inactive_anonymous_users(30)

    if count > 0 do
      Logger.info("Deleted #{count} inactive anonymous user(s)")
    else
      Logger.info("No inactive anonymous users to delete")
    end

    schedule_cleanup()
    {:noreply, state}
  end

  defp schedule_cleanup do
    # Schedule next cleanup in 24 hours
    Process.send_after(self(), :cleanup_anonymous_users, @cleanup_interval)
  end
end
