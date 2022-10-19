defmodule Ptolemy.Controllers.Auth.Login do
  use Plug.Builder
  alias Ptolemy.Schemas.User, as: User
  import Ptolemy.Helpers.Validators, only: [validate_body_params: 2]
  import Plug.CSRFProtection

  plug(:fetch_session)

  plug(Plug.Parsers, parsers: [:json], json_decoder: Jason)
  plug(:validate_body_params, ["username", "password"])
  plug(:handle_request)

  def handle_request(conn, _opts) do
    # Make sure we start a new session on each login
    conn = configure_session(conn, renew: true)
    params = conn.assigns[:validated_body_params]

    with user when not is_nil(user) <- Ptolemy.Repo.get_by(User, username: params["username"]) do
      provided_password =
        Base.encode64(:crypto.hash(:sha256, "#{params["password"]}:#{user.salt}"))

      if provided_password == user.password do
        delete_csrf_token()
        fresh_token = get_csrf_token()

        # TODO: I can make the cookie much smaller by just storing an ID
        # and storing all the information server-side in a genserver process.
        conn
        |> put_session(:authenticated_user, user)
        |> put_resp_header("x-csrf-token", fresh_token)
        |> send_resp(200, "Success")
        |> halt()
      else
        # Make sure to drop the session so that we don't send any session cookie.
        conn = configure_session(conn, drop: true)
        halt(send_resp(conn, 401, "Unauthorized"))
      end
    else
      _ ->
        conn = configure_session(conn, drop: true)
        halt(send_resp(conn, 401, "Unauthorized"))
    end
  end
end
