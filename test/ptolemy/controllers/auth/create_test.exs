defmodule Ptolemy.Controllers.Auth.CreateTest do
  use Ptolemy.Case
  use Plug.Test

  import Mox
  import Ptolemy.AuthHelpers

  alias Ptolemy.Schemas.User
  alias Ptolemy.Schemas.VerificationCode
  alias Ptolemy.Controllers.Auth.Create

  setup :verify_on_exit!

  test "successful creation of an account" do
    Ptolemy.Services.MockMailer
    |> expect(
      :send_email,
      1,
      fn _subject, _html_body, _recipients -> :ok end
    )

    conn = create_user("test@example.com", "jds", "sooper_secret")

    assert conn.state == :sent
    assert conn.status == 201

    new_user = Repo.get_by!(User, email: "test@example.com")
    assert new_user.email_verification_status == "pending"

    code = Repo.get_by!(VerificationCode, email: "test@example.com")
    assert code != nil
  end

  test "account creation fails when insufficient parameters supplied" do
    request_body = Jason.encode!(%{
      email: "test@example.com",
      username: "jds",
    })

    opts = Create.init([])

    conn =
      :post
      |> conn("/auth/create", request_body)
      |> put_req_header("content-type", "application/json")
      |> Create.call(opts)

    assert conn.state == :sent
    assert conn.status == 422
    assert conn.resp_body == "Required parameter `password` was not found"
  end

  test "account creation fails when any parameter is blank" do
    Ptolemy.Services.MockMailer
    |> expect(
      :send_email,
      0,
      fn _subject, _html_body, _recipients -> :ok end
    )

    conn = create_user("test@example.com", "jds", "")

    assert conn.state == :sent
    assert conn.status == 422
    assert conn.resp_body == "Required parameter `password` cannot be blank"

    conn = create_user("test@example.com", "", "12345")

    assert conn.state == :sent
    assert conn.status == 422
    assert conn.resp_body == "Required parameter `username` cannot be blank"
  end

  test "account creation fails when email already taken" do
    Ptolemy.Services.MockMailer
    |> expect(
      :send_email,
      1,
      fn _subject, _html_body, _recipients -> :ok end
    )

    conn = create_user("test@example.com", "jds", "sooper_secret")

    assert conn.state == :sent
    assert conn.status == 201

    conn = create_user("test@example.com", "abc", "12345")

    assert conn.state == :sent
    assert conn.status == 422
    parsed_body = Jason.decode!(conn.resp_body)
    assert parsed_body["kind"] == "DuplicateFields"
    assert match?(["email"], parsed_body["details"]["fields"])

    # here we're just checking that the other user was created properly
    # and not affected by the other account creation (no extra VC, for ex)
    new_user = Repo.get_by!(User, email: "test@example.com")
    assert new_user.email_verification_status == "pending"

    code = Repo.get_by!(VerificationCode, email: "test@example.com")
    assert code != nil
  end

  test "account creation fails when username already taken" do
    Ptolemy.Services.MockMailer
    |> expect(
      :send_email,
      1,
      fn _subject, _html_body, _recipients -> :ok end
    )

    conn = create_user("test@example.com", "jds", "sooper_secret")

    assert conn.state == :sent
    assert conn.status == 201

    conn = create_user("other_email@example.com", "jds", "12345")

    assert conn.state == :sent
    assert conn.status == 422
    parsed_body = Jason.decode!(conn.resp_body)
    assert parsed_body["kind"] == "DuplicateFields"
    assert match?(["username"], parsed_body["details"]["fields"])

    # Again, just checking the user is still set up right.
    new_user = Repo.get_by!(User, email: "test@example.com")
    assert new_user.email_verification_status == "pending"

    code = Repo.get_by!(VerificationCode, email: new_user.email)
    assert code != nil
  end
end
