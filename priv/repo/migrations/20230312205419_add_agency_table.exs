defmodule Ptolemy.Repo.Migrations.AddAgencyTable do
  use Ecto.Migration

  def change do
    create table("agencies") do
      add :owner_id, references("users",
        on_delete: :delete_all
      ), null: false
      add :credits, :integer, null: false, default: 50000
    end
  end
end
