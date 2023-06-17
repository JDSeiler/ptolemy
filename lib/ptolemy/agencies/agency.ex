defmodule Ptolemy.Agencies.Agency do
  use Ecto.Schema
  import Ecto.Changeset

  schema "agencies" do
    field :agency_name, :string
    field :balance, :decimal
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(agency, attrs) do
    agency
    |> cast(attrs, [:agency_name, :balance])
    |> validate_required([:agency_name, :balance])
  end
end
