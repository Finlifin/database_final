defmodule DatabaseFinal.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      DatabaseFinalWeb.Telemetry,
      DatabaseFinal.Repo,
      {DNSCluster, query: Application.get_env(:database_final, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: DatabaseFinal.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: DatabaseFinal.Finch},
      # Start a worker by calling: DatabaseFinal.Worker.start_link(arg)
      # {DatabaseFinal.Worker, arg},
      # Start to serve requests, typically the last entry
      DatabaseFinalWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: DatabaseFinal.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    DatabaseFinalWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
