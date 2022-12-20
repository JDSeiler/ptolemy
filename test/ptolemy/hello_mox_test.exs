defmodule Ptolemy.HelloMoxTest do
  use Ptolemy.Case
  use Plug.Test

  import Mox

  alias Ptolemy.Controllers.Auth.Create
  alias Ptolemy.Schemas.User
  alias Ptolemy.Schemas.VerificationCode

  @opts Create.init([])

  # Mox verifies all of the `expect` assertions for the entire test suite
  # Each expect call is a separate invocation of the mock.
  setup :verify_on_exit!

  test "successful creation of an account" do
    Ptolemy.Services.MockMailer
    |> expect(
      :send_email,
      1,
      fn _subject, _html_body, _recipients -> :ok end
    )

    request_body =
      Jason.encode!(%{
        email: "test@example.com",
        username: "jds",
        password: "sooper_secret"
      })

    conn =
      :post
      |> conn("/auth/create", request_body)
      |> put_req_header("content-type", "application/json")

    conn = Create.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 201

    verify_user_added =
      from(u in User,
        where: u.email == "test@example.com",
        select: u
      )

    matching_users = Repo.all(verify_user_added)

    assert length(matching_users) == 1
    assert List.first(matching_users).email_verification_status == "pending"

    verify_code_added =
      from(c in VerificationCode,
        where: c.email == "test@example.com",
        select: c
      )

    matching_codes = Repo.all(verify_code_added)

    assert length(matching_codes) == 1
  end
end
