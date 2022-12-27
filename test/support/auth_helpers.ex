defmodule Ptolemy.AuthHelpers do
  use Plug.Test

  alias Ptolemy.Controllers.Auth.Verify
  alias Ptolemy.Schemas.VerificationCode
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

  @spec verify_email(String.t()) :: Plug.Conn.t()
  @doc """
  Attempts to verify the provided email by searching the database for
  a verification code, and sending a request to /auth/verify. If no
  code is found, the `code` parameter of the verify endpoint is set
  to an empty string, causing the request to fail.
  """
  def verify_email(email) do
    maybe_code = case Ptolemy.Repo.get_by(VerificationCode, email: email) do
      nil -> ""
      vc -> vc.code
    end

    opts = Verify.init([])

    conn =
      :post
      |> conn("/auth/verify?email=#{email}&code=#{maybe_code}")
      |> put_req_header("content-type", "application/json")
      |> Verify.call(opts)

    conn
  end
end
