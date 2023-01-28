defmodule Ptolemy.Controllers.Auth.Heartbeat do
  use Plug.Builder
  import Ptolemy.Services.Authorizer

  plug(:authorize)
  plug(:handle_request)

  def handle_request(conn, _opts) do
    send_resp(conn, 204, "")
  end
end
