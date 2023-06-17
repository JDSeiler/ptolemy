defmodule Ptolemy.Repo.Migrations.CreateAgencies do
  use Ecto.Migration

  def change do
    create table(:agencies) do
      add :agency_name, :text
      add :balance, :decimal
      # If a user deletes their account, all their agencies should be destroyed too
      # TODO: This reference is nullable, which is probably not good.
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create index(:agencies, [:user_id])
  end
end
