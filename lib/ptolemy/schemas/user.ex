defmodule Ptolemy.Schemas.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email
    field :username
    field :password
    field :salt
    field :email_verification_status
  end

  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [:email, :username, :password, :salt, :email_verification_status])
    |> validate_required([:email, :username, :password, :salt, :email_verification_status])
    |> validate_inclusion(:email_verification_status, ["unverified", "pending", "verified"])
    |> unique_constraint([:email])
    |> unique_constraint([:username])
  end
end
