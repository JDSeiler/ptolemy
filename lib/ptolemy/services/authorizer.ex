defmodule Ptolemy.Services.Authorizer do
  use Plug.Builder

  def authorize(conn, _opts) do
    user = fetch_session(conn)
           |> get_session("authenticated_user")

    if nil?(user) do
      send_resp(conn, 401, "Unauthorized") |> halt()
    else
      conn
    end

  end

  defp nil?(nil), do: true
  defp nil?(_), do: false
end
