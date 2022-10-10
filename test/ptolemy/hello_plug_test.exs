defmodule Ptolemy.HelloPlugTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @opts Ptolemy.HelloPlug.init([])

  test "returns a greeting" do
    conn = conn(:get, "/hello/bob")

    conn = Ptolemy.HelloPlug.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "Hello bob!"
  end

  test "returns a 404" do
    conn = conn(:get, "/junk/route")

    conn = Ptolemy.HelloPlug.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 404
    assert conn.resp_body == "not found!"
  end
end
