defmodule Ptolemy.Controllers.Auth.VerifyTest do
  use Ptolemy.Case
  use Plug.Test

  import Mox
  import Ptolemy.AuthHelpers

  alias Ptolemy.Controllers.Auth.Verify
  alias Ptolemy.Schemas.VerificationCode
  alias Ptolemy.Schemas.User

  @opts Verify.init([])

  setup :verify_on_exit!

  test "verification is successful when provided the correct code" do
    Ptolemy.Services.MockMailer
    |> expect(
      :send_email,
      1,
      fn _subject, _html_body, _recipients -> :ok end
    )

    create_user("test@example.com", "jds", "sooper_secret")

    %{ code: code } = Repo.get_by!(VerificationCode, email: "test@example.com")

    conn =
      :post
      |> conn("/auth/verify?email=test@example.com&code=#{code}")
      |> Verify.call(@opts)

    assert conn.state == :sent
    assert conn.status == 204

    %{ email_verification_status: status } = Repo.get_by!(User, email: "test@example.com")
    assert status == "verified"
  end

  test "verification fails when provided wrong code" do
    Ptolemy.Services.MockMailer
    |> expect(
      :send_email,
      1,
      fn _subject, _html_body, _recipients -> :ok end
    )

    create_user("test@example.com", "jds", "sooper_secret")

    conn =
      :post
      |> conn("/auth/verify?email=test@example.com&code=junk")
      |> Verify.call(@opts)

    assert conn.state == :sent
    assert conn.status == 422
  end

  test "verification fails when providing unknown email" do
    Ptolemy.Services.MockMailer
    |> expect(
      :send_email,
      1,
      fn _subject, _html_body, _recipients -> :ok end
    )

    create_user("test@example.com", "jds", "sooper_secret")

    conn =
      :post
      |> conn("/auth/verify?email=unknown@example.com&code=junk")
      |> Verify.call(@opts)
    
    assert conn.state == :sent
    assert conn.status == 422
  end
end
