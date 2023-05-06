defmodule Leadfoot.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      LeadfootWeb.Telemetry,
      Leadfoot.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Leadfoot.PubSub},
      {Leadfoot.GearRatios, []},
      {Leadfoot.ReadUdp, []},
      {Leadfoot.LapTimes, []},
      {Finch, name: Leadfoot.Finch},
      # Start the Endpoint (http/https)
      LeadfootWeb.Endpoint,
      {Registry, keys: :unique, name: Leadfoot.Session.Registry},
      {DynamicSupervisor, name: Leadfoot.Session.Supervisor, strategy: :one_for_one}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Leadfoot.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LeadfootWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
