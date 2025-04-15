defmodule FoodTracker.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      FoodTrackerWeb.Telemetry,
      FoodTracker.Repo,
      {Ecto.Migrator,
        repos: Application.fetch_env!(:food_tracker, :ecto_repos),
        skip: skip_migrations?()},
      {DNSCluster, query: Application.get_env(:food_tracker, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: FoodTracker.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: FoodTracker.Finch},
      # Start a worker by calling: FoodTracker.Worker.start_link(arg)
      # {FoodTracker.Worker, arg},
      # Start to serve requests, typically the last entry
      FoodTrackerWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: FoodTracker.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FoodTrackerWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp skip_migrations?() do
    # By default, sqlite migrations are run when using a release
    System.get_env("RELEASE_NAME") != nil
  end
end
