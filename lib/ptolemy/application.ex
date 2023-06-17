defmodule Ptolemy.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      PtolemyWeb.Telemetry,
      # Start the Ecto repository
      Ptolemy.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Ptolemy.PubSub},
      # Start Finch
      {Finch, name: Ptolemy.Finch},
      # Start the Endpoint (http/https)
      PtolemyWeb.Endpoint
      # Start a worker by calling: Ptolemy.Worker.start_link(arg)
      # {Ptolemy.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Ptolemy.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PtolemyWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
