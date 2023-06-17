defmodule Ptolemy.AgenciesTest do
  use Ptolemy.DataCase

  alias Ptolemy.Agencies

  describe "agencies" do
    alias Ptolemy.Agencies.Agency

    import Ptolemy.AgenciesFixtures

    @invalid_attrs %{agency_name: nil, balance: nil}

    test "list_agencies/0 returns all agencies" do
      agency = agency_fixture()
      assert Agencies.list_agencies() == [agency]
    end

    test "get_agency!/1 returns the agency with given id" do
      agency = agency_fixture()
      assert Agencies.get_agency!(agency.id) == agency
    end

    test "create_agency/1 with valid data creates a agency" do
      valid_attrs = %{agency_name: "some agency_name", balance: "120.5"}

      assert {:ok, %Agency{} = agency} = Agencies.create_agency(valid_attrs)
      assert agency.agency_name == "some agency_name"
      assert agency.balance == Decimal.new("120.5")
    end

    test "create_agency/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Agencies.create_agency(@invalid_attrs)
    end

    test "update_agency/2 with valid data updates the agency" do
      agency = agency_fixture()
      update_attrs = %{agency_name: "some updated agency_name", balance: "456.7"}

      assert {:ok, %Agency{} = agency} = Agencies.update_agency(agency, update_attrs)
      assert agency.agency_name == "some updated agency_name"
      assert agency.balance == Decimal.new("456.7")
    end

    test "update_agency/2 with invalid data returns error changeset" do
      agency = agency_fixture()
      assert {:error, %Ecto.Changeset{}} = Agencies.update_agency(agency, @invalid_attrs)
      assert agency == Agencies.get_agency!(agency.id)
    end

    test "delete_agency/1 deletes the agency" do
      agency = agency_fixture()
      assert {:ok, %Agency{}} = Agencies.delete_agency(agency)
      assert_raise Ecto.NoResultsError, fn -> Agencies.get_agency!(agency.id) end
    end

    test "change_agency/1 returns a agency changeset" do
      agency = agency_fixture()
      assert %Ecto.Changeset{} = Agencies.change_agency(agency)
    end
  end
end
