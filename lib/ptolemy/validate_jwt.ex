defmodule Ptolemy.ValidateJwt do
  def init(opts), do: opts

  def call(conn, _opts) do
    with {:ok, token} <- extract_bearer_token(conn),
         {:ok, _claims} <- Ptolemy.Token.verify_and_validate(token) do
      # TODO: Maybe do some extra checking of the claims, if necessary.
      
      # If we make it this far, then we're good, forward the connection!
      conn
    else
      # If any match failed, the auth header isn't good and we should stop the request
      # This is where we could split out into different error handlers if we want.
      # Regardless, it's important that we use `halt` so that Plug doesn't
      # continue running the pipeline.
      _ -> Plug.Conn.halt Plug.Conn.send_resp(conn, 401, "Unauthorized")
      # It'd be nice to have messages for expired credentials.
    end
  end

  defp extract_bearer_token(conn) do
    with [header_value] <- Plug.Conn.get_req_header(conn, "authorization") do
      ["Bearer", token] = String.split(header_value)
      {:ok, token}
    else
      _ -> {:error, :not_found}
    end
  end
end
