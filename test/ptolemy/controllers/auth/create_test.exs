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
    assert conn.resp_body == "{\"details\":[\"email has the following error: has already been taken\"],\"message\":\"Unprocessable Entity\"}"

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
    assert conn.resp_body == "{\"details\":[\"username has the following error: has already been taken\"],\"message\":\"Unprocessable Entity\"}"

    verify_user_added =
      from(u in User,
        where: u.username == "jds",
        select: u
      )
    matching_users = Repo.all(verify_user_added)

    assert length(matching_users) == 1
    assert List.first(matching_users).email_verification_status == "pending"

    user_email = List.first(matching_users).email

    verify_code_added =
      from(c in VerificationCode,
        where: c.email == ^user_email,
        select: c
      )
    matching_codes = Repo.all(verify_code_added)

    assert length(matching_codes) == 1
  end
end
