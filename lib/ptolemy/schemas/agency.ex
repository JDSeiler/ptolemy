defmodule Ptolemy.Schemas.Agency do
  use Ecto.Schema
  alias Ptolemy.Schemas.User, as: User
  import Ecto.Changeset

  schema "agency" do
    field :credits, :integer, default: 50000
    belongs_to :user, User,
      foreign_key: :owner_id,
      references: :id,
      define_field: false
  end

  def changeset(agency, params \\ %{}) do
    agency
    |> cast(params, [:credits, :owner_id])
    |> validate_required([:credits, :owner_id])
    |> foreign_key_constraint(:owner_id)
  end
end
