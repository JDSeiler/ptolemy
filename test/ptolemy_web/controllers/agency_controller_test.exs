defmodule PtolemyWeb.AgencyControllerTest do
  use PtolemyWeb.ConnCase

  import Ptolemy.AgenciesFixtures

  @create_attrs %{agency_name: "some agency_name", balance: "120.5"}
  @update_attrs %{agency_name: "some updated agency_name", balance: "456.7"}
  @invalid_attrs %{agency_name: nil, balance: nil}

  describe "index" do
    test "lists all agencies", %{conn: conn} do
      conn = get(conn, ~p"/agencies")
      assert html_response(conn, 200) =~ "Listing Agencies"
    end
  end

  describe "new agency" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/agencies/new")
      assert html_response(conn, 200) =~ "New Agency"
    end
  end

  describe "create agency" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/agencies", agency: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/agencies/#{id}"

      conn = get(conn, ~p"/agencies/#{id}")
      assert html_response(conn, 200) =~ "Agency #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/agencies", agency: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Agency"
    end
  end

  describe "edit agency" do
    setup [:create_agency]

    test "renders form for editing chosen agency", %{conn: conn, agency: agency} do
      conn = get(conn, ~p"/agencies/#{agency}/edit")
      assert html_response(conn, 200) =~ "Edit Agency"
    end
  end

  describe "update agency" do
    setup [:create_agency]

    test "redirects when data is valid", %{conn: conn, agency: agency} do
      conn = put(conn, ~p"/agencies/#{agency}", agency: @update_attrs)
      assert redirected_to(conn) == ~p"/agencies/#{agency}"

      conn = get(conn, ~p"/agencies/#{agency}")
      assert html_response(conn, 200) =~ "some updated agency_name"
    end

    test "renders errors when data is invalid", %{conn: conn, agency: agency} do
      conn = put(conn, ~p"/agencies/#{agency}", agency: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Agency"
    end
  end

  describe "delete agency" do
    setup [:create_agency]

    test "deletes chosen agency", %{conn: conn, agency: agency} do
      conn = delete(conn, ~p"/agencies/#{agency}")
      assert redirected_to(conn) == ~p"/agencies"

      assert_error_sent 404, fn ->
        get(conn, ~p"/agencies/#{agency}")
      end
    end
  end

  defp create_agency(_) do
    agency = agency_fixture()
    %{agency: agency}
  end
end
