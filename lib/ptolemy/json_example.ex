defmodule Ptolemy.JsonExample do
  use Plug.Router

  plug Plug.Parsers, parsers: [:json], json_decoder: Jason
  plug :match
  plug :dispatch

  post "/add" do
    IO.inspect( conn.body_params )
    conn = Plug.Conn.put_resp_header(conn, "content-type", "application/json")
    # Expects {"operands": number[]}
    sum = Enum.sum(conn.body_params["operands"])
    {:ok, token, _claims} = Ptolemy.Token.generate_and_sign(%{"sub" => "user_number #{sum}"})
    {:ok, resp_body} = Jason.encode(%{token: token})
    send_resp(conn, 200, resp_body)
  end
end
