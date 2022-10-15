defmodule Ptolemy.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    port = 4001
    children = [
      Ptolemy.Repo,
      {Plug.Cowboy, scheme: :http, plug: Ptolemy.RootRouter, options: [port: port]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Ptolemy.Supervisor]
    IO.puts("Listening on localhost:#{port}")
    Supervisor.start_link(children, opts)
  end
end
