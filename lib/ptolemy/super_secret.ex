defmodule Ptolemy.SuperSecret do
  use Plug.Builder

  # Here, we protect an endpoint using our validation plug by simply including
  # it in the pipeline. If the request doesn't have a valid Authorization
  # header then it will terminate with the appropriate HTTP error code.
  plug Ptolemy.ValidateJwt

  plug :handle_request

  def handle_request(conn, _opts) do
    send_resp(conn, 200, "The secret is 42")
  end
end
