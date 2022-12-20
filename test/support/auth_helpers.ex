defmodule Ptolemy.AuthHelpers do
  use Plug.Test

  alias Ptolemy.Controllers.Auth.Create

  @spec create_user(String.t(), String.t(), String.t()) :: Plug.Conn.t()
  @doc """
  Creates a new user by POSTing the provided email, username, and password
  to /auth/create. The connection object is returned for assertions or
  further calls.
  """
  def create_user(email, username, password) do
    request_body = Jason.encode!(%{
      email: email,
      username: username,
      password: password
    })

    opts = Create.init([])

    conn =
      :post
      |> conn("/auth/create", request_body)
      |> put_req_header("content-type", "application/json")
      |> Create.call(opts)

    conn
  end
end
