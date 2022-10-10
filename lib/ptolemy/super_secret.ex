defmodule Ptolemy.SuperSecret do
  use Plug.Builder

  # This is just to test how plugs behave when you specify
  # them at different levels of the plug tree.
  import Plug.BasicAuth
  plug :basic_auth, username: "admin", password: "password"

  plug :handle_request

  def handle_request(conn, _opts) do
    send_resp(conn, 200, "The secret is 42")
  end
end
