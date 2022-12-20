defmodule Ptolemy.Helpers.ValidatorsTest do
  use ExUnit.Case, async: true
  use Plug.Test

  import Ptolemy.Helpers.Validators

  test "validate_query_params succeeds when params exactly match" do
    conn = conn(:get, "/dud?name=bob&age=35")
    conn = validate_query_params(conn, ["name", "age"])

    params = conn.assigns[:validated_query_params]
    assert ^params = %{"name" => "bob", "age" => "35"}
  end

  test "validate_query_params trims extra parameters" do
    conn = conn(:get, "/dud?name=bob&age=35&job=cryptographer")
    conn = validate_query_params(conn, ["name", "age"])

    params = conn.assigns[:validated_query_params]
    assert ^params = %{"name" => "bob", "age" => "35"}
  end

  test "validate_query_params halts as soon as it finds a missing param" do
    conn = conn(:get, "/dud?name=bob&shoe_size=12&job=cryptographer")
    conn = validate_query_params(conn, ["name", "age", "job"])

    assert conn.halted == true
    assert conn.status == 422
    assert conn.resp_body == "Required parameter `age` was not found"
  end

  test "validate_query_params resists a malformed query string" do
    conn = conn(:get, "/dud?name=bob&jun&=k&age=35")
    conn = validate_query_params(conn, ["name", "age"])

    params = conn.assigns[:validated_query_params]
    assert ^params = %{"name" => "bob", "age" => "35"}
  end

  test "validate_body_params succeeds when params exactly match" do
    body = Jason.encode!(%{
      language: "Elixir",
      important_info: 42
    })

    conn = prepare_test_connection(body)

    conn = validate_body_params(conn, ["language", "important_info"])
    params = conn.assigns[:validated_body_params]
    # Note that types are preserved with body parameters! Query parameters
    # are always strings.
    assert ^params = %{"language" => "Elixir", "important_info" => 42}
  end

  test "validate_body_params trims extra parameters" do
    body = Jason.encode!(%{
      make: "Ford",
      model: "Escort",
      doors: 4,
      headlights: true
    })

    conn = prepare_test_connection(body)

    conn = validate_body_params(conn, ["make", "model"])
    params = conn.assigns[:validated_body_params]
    assert ^params = %{"make" => "Ford", "model" => "Escort"}
  end

  test "validate_body_params halts as soon as it finds a missing param" do
    body = Jason.encode!(%{
      make: "Ford",
      model: "Escort",
    })

    conn = prepare_test_connection(body)

    conn = validate_body_params(conn, ["make", "doors", "model"])

    assert conn.halted == true
    assert conn.status == 422
    assert conn.resp_body == "Required parameter `doors` was not found"
  end

  test "validate_body_params never called with malformed request body" do
    assert_raise Plug.Parsers.ParseError, fn ->
      prepare_test_connection("{ \"age\": 15 ")
    end
  end

  # Creates a POST request with the correct content-type,
  # then manually invokes Plug.Parsers.JSON and populates
  # the body_params property of the connection with the result
  defp prepare_test_connection(encoded_body) do
    conn =
      :post
      |> conn("/dud", encoded_body)
      |> put_req_header("content-type", "application/json")

    opts = Plug.Parsers.JSON.init(json_decoder: Jason)
    {:ok, body_params, conn} = Plug.Parsers.JSON.parse(conn, "application", "json", %{}, opts)
    %{conn | body_params: body_params }
  end
end
