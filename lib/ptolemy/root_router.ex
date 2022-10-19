defmodule Ptolemy.RootRouter do
  use Plug.Router

  plug Plug.Logger
  plug :put_secret_key_base
  plug :match
  plug :dispatch

  if Mix.env == :dev do
    use Plug.Debugger
  end

  use Plug.ErrorHandler

  # Route planning
  # /auth/create
  # /auth/verify
  # /auth/login

  # Big change in how this will work....
  # create and verify will work as originally planned...
  # login will also be basically the same. But instead of returning a JWT, it's
  # going to simply set a session cookie combined with CSRF protection.

  forward "/auth", to: Ptolemy.Routes.Auth

  # Ripped straight from the Plug.Router logs
  defp handle_errors(conn, %{kind: _kind, reason: _reason, stack: _stack}) do
    send_resp(conn, conn.status, "Something went wrong")
  end

  # This is pulled from the Plug.Session.COOKIE, docs
  defp put_secret_key_base(conn, _) do
    put_in(conn.scret_key_base, Application.get_env(:ptolemy, Ptolemy.Keys))
  end
end
