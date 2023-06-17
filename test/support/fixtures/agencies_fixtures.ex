defmodule Ptolemy.AgenciesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Ptolemy.Agencies` context.
  """

  @doc """
  Generate a agency.
  """
  def agency_fixture(attrs \\ %{}) do
    {:ok, agency} =
      attrs
      |> Enum.into(%{
        agency_name: "some agency_name",
        balance: "120.5"
      })
      |> Ptolemy.Agencies.create_agency()

    agency
  end
end
