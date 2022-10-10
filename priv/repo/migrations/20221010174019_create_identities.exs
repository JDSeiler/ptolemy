defmodule Ptolemy.Repo.Migrations.CreateIdentities do
  use Ecto.Migration

  # Write a single "change" fucntion and Ecto will figure out the reverse
  # operation for you. Alternately, you can write `up` and `down` functions
  # individually. Not all opeations are reversible! So pay attention.
  def change do
    create table("identities", primary_key: [name: :user_id, type: :bigserial]) do
      add :username, :text, null: false
      add :password, :text, null: false
      add :salt, :text, null: false
      add :email_verification_status, :text, default: "unverified", null: false
    end

    create constraint(
      "identities",
      :verification_status_valid,
      check: "email_verification_status IN ('unverified', 'pending', 'verified')"
    )
  end
end
