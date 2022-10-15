defmodule Ptolemy.Schemas.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ptolemy.Schemas.VerificiationCode, as: VerificationCode

  schema "users" do
    field :email
    field :username
    field :password
    field :salt
    field :email_verification_status
    has_one :code, VerificationCode,
      foreign_key: :email,
      references: :email,
      on_replace: :update
  end

  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [:email, :username, :password, :salt, :email_verification_status])
    |> validate_required([:email, :username, :password, :salt, :email_verification_status])
    # TODO: Do I even need the three states? Maybe just have two?
    |> validate_inclusion(:email_verification_status, ["unverified", "pending", "verified"])
    |> unique_constraint([:email])
    |> unique_constraint([:username])
  end
end
