defmodule Ptolemy.Schemas.VerificationCode do
  use Ecto.Schema
  alias Ptolemy.Schemas.User, as: User

  schema "verification_codes" do
    field :email
    field :code
    belongs_to :user, User,
      foreign_key: :email,
      references: :email,
      define_field: false
  end
end
