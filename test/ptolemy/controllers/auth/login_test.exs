defmodule Ptolemy.Controllers.Auth.LoginTest do
  use Ptolemy.Case
  use Plug.Test

  import Mox
  import Ptolemy.AuthHelpers

  setup context do
    verify_on_exit!(context)

    Ptolemy.Services.MockMailer
    |> expect(
      :send_email,
      1,
      fn _subject, _html_body, _recipients -> :ok end
    )

    create_user("test@example.com", "jds", "sooper_secret")
    verify_email("test@example.com")
    :ok
  end

  test "successful login" do
    conn = send_login_req("jds", "sooper_secret")

    assert conn.state == :sent
    assert conn.status == 200
  end

  test "failed login due to wrong username" do
    conn = send_login_req("stranger_danger", "sooper_secret")

    assert conn.state == :sent
    assert conn.status == 401

    parsed_body = Jason.decode!(conn.resp_body)
    assert parsed_body["kind"] == "InvalidCredentials"
  end

  test "failed login due to wrong password" do
    conn = send_login_req("jds", "wrong_password")

    assert conn.state == :sent
    assert conn.status == 401

    parsed_body = Jason.decode!(conn.resp_body)
    assert parsed_body["kind"] == "InvalidCredentials"
  end

  test "failed login due to unverified email" do
    # `expect` calls accumulate. I expect `send_email` to be called
    # once in my setup, and I expect it to be called once in this test.
    # At verification time, we expect 2 total calls to `send_email`
    Ptolemy.Services.MockMailer
     |> expect(
       :send_email,
       1,
       fn _subject, _html_body, _recipients -> :ok end
     )

    create_user("junkmail@example.com", "wont_verify", "sooper_secret")

    conn = send_login_req("wont_verify", "sooper_secret")

    assert conn.state == :sent
    assert conn.status == 401

    parsed_body = Jason.decode!(conn.resp_body)
    assert parsed_body["kind"] == "UnverifiedEmail"
  end

  test "successful login creates a session" do
    conn = send_login_req("jds", "sooper_secret")

    authenticated_user = get_session(conn, :authenticated_user)

    assert match?(
             %{
               id: _,
               email: "test@example.com",
               email_verification_status: "verified",
               username: "jds"
             },
             authenticated_user
           )
  end

  test "successful login returns a session cookie" do
    conn = send_login_req("jds", "sooper_secret")

    assert match?(
             %{
               "_ptolemy" => %{http_only: true, value: _}
             },
             conn.resp_cookies
           )
  end
end
