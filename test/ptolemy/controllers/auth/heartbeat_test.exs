defmodule Ptolemy.Controllers.Auth.HeartbeatTest do
  use Ptolemy.Case
  use Plug.Test

  import Mox
  import Ptolemy.AuthHelpers

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
    verify_email("test@example.com")
    :ok
  end

  test "heartbeat endpoint returns a 204 if valid session cookie provided" do
    login_conn = send_login_req("jds", "sooper_secret")

    conn =
      :get
      |> conn("/auth/heartbeat")
      |> recycle_cookies(login_conn)
      |> Root.call(@opts)

    assert conn.state == :sent
    assert conn.status == 204
  end

  test "heartbeat endpoint returns a 401 if no session cookie provided" do
    conn =
      :get
      |> conn("/auth/heartbeat")
      |> Root.call(@opts)

    assert conn.state == :sent
    assert conn.status == 401
  end

  test "heartbeat endpoint returns a 401 if invalid session provided" do
    conn =
      :get
      |> conn("/auth/heartbeat")
      |> put_req_cookie("_ptolemy", "JUNK")
      |> Root.call(@opts)

    assert conn.state == :sent
    assert conn.status == 401
  end
end
