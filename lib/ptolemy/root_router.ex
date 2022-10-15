defmodule Ptolemy.RootRouter do
  use Plug.Router

  plug Plug.Logger
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
  # /auth/refresh

  # 1. User sends a POST request to /auth/create with an email, username, and password
  # 2a. The create endpoint makes the user in Postgres. Hashes the password with a salt.
  # 2b. The create endpoint sends an email with a verification code (random number). The number
  #     is stored in ETS and associated with the email.
  # 3. The verification email contains a link to a frontend page and contains the verification code
  #    and email in the query parameters. The frontend page extracts the info and sends it to `/auth/verify
  # 4. /auth/verify checks that the verification code matches and marks the user as verified. The response
  #    indicates to the frontend that verification was a success and the user is redirected to the login.
  # 5. The login endpoint gets the username and password, it hashes the password with the salt and returns a signed
  #    JWT on login success.
  # 6. /auth/refresh takes a valid, unexpired JWT and returns a JWT with identical contents except the expiry has
  #    and nbt have been updated/extended.

  forward "/auth", to: Ptolemy.Routes.Auth

  # Ripped straight from the Plug.Router logs
  defp handle_errors(conn, %{kind: _kind, reason: _reason, stack: _stack}) do
    send_resp(conn, conn.status, "Something went wrong")
  end
end
