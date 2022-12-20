defmodule Ptolemy.Controllers.Auth.Login do
  use Plug.Builder
  alias Ptolemy.Schemas.User, as: User
  import Ptolemy.Helpers.Validators, only: [validate_body_params: 2]
  import Ptolemy.Helpers.Responses
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

      # TODO: I need to verify the user is... verified... before I sign them in.
      if provided_password == user.password do
        delete_csrf_token()
        fresh_token = get_csrf_token()

        # TODO: I can make the cookie much smaller by just storing an ID
        # and storing all the information server-side in a genserver process.
        conn
        |> put_session(:authenticated_user, filter_sensitive_user_info(user))
        |> put_resp_header("x-csrf-token", fresh_token)
        |> put_resp_header("content-type", "application/json")
        |> send_resp(200, information("Ok"))
        |> halt()
      else
        # Make sure to drop the session so that we don't send any session cookie.
        configure_session(conn, drop: true)
        |> put_resp_header("content-type", "application/json")
        |> send_resp(401, information("Unauthorized", ["Username or password is incorrect"]))
        |> halt()
      end
    else
      _ ->
        configure_session(conn, drop: true)
        |> put_resp_header("content-type", "application/json")
        |> send_resp(401, information("Unauthorized", ["Username or password is incorrect"]))
        |> halt()
    end
  end

  # The session is sent to the user as an encrypted and signed cookie. Despite
  # being encrypted, we should avoid sending sensitive or useless fields entirely.
  defp filter_sensitive_user_info(user) do
    Map.from_struct(user)
    |> Map.drop([:password, :salt, :code, :__meta__])
  end
end
