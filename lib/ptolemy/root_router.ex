defmodule Ptolemy.RootRouter do
  use Plug.Router

  plug Plug.Logger
  plug :put_secret_key_base
  plug Plug.Session, store: :cookie,
                     key: "_ptolemy",
                     http_only: true,
                     # TODO: use Secure attribute on the cookie
                     encryption_salt: Application.get_env(:ptolemyl, :encryption_salt),
                     signing_salt: Application.get_env(:ptolemy, :signing_salt),
                     log: :debug
  plug :match
  plug :dispatch

  if Mix.env == :dev do
    use Plug.Debugger
  end

  use Plug.ErrorHandler

  forward "/auth", to: Ptolemy.Routes.Auth

  # Ripped straight from the Plug.Router logs
  defp handle_errors(conn, %{kind: _kind, reason: _reason, stack: _stack}) do
    send_resp(conn, conn.status, "Something went wrong")
  end

  # This is pulled from the Plug.Session.COOKIE docs
  defp put_secret_key_base(conn, _) do
    put_in(conn.secret_key_base, Application.get_env(:ptolemy, :secret_key_base))
  end
end
