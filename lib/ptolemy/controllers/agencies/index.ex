defmodule Ptolemy.Controllers.Agencies.Index do
  use Plug.Builder

  plug :handle_request

  def handle_request(conn, _opts) do
   send_resp(conn, 418, "I'm a stub... Uh, I mean \"I'm a teapot!\"")
  end
end
