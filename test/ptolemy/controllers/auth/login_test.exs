defmodule Ptolemy.Controllers.Auth.LoginTest do
  use Ptolemy.Case
  use Plug.Test

  import Mox
  import Ptolemy.AuthHelpers

  # Here we need to use the entire Plug pipeline because the
  # RootRouter contains all the Session configuration.
  alias Ptolemy.RootRouter, as: Root

  @opts Root.init([])

  setup context do
    verify_on_exit!(context)

    Ptolemy.Services.MockMailer
    |> expect(
      :send_email,
      1,
      fn _subject, _html_body, _recipients -> :ok end
    )

    create_user("test@example.com", "jds", "sooper_secret")
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

    assert conn.resp_body ==
             "{\"details\":[\"Username or password is incorrect\"],\"message\":\"Unauthorized\"}"
  end

  test "failed login due to wrong password" do
    conn = send_login_req("jds", "wrong_password")

    assert conn.state == :sent
    assert conn.status == 401

    assert conn.resp_body ==
             "{\"details\":[\"Username or password is incorrect\"],\"message\":\"Unauthorized\"}"
  end

  test "successful login creates a session" do
    conn = send_login_req("jds", "sooper_secret")

    authenticated_user = get_session(conn, :authenticated_user)

    assert match?(
             %{
               id: _,
               email: "test@example.com",
               email_verification_status: "pending",
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

  defp send_login_req(username, password) do
    body =
      Jason.encode!(%{
        username: username,
        password: password
      })

    :post
    |> conn("/auth/login", body)
    |> put_req_header("content-type", "application/json")
    |> Root.call(@opts)
  end
end
