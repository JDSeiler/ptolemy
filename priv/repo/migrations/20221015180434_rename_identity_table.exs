defmodule Ptolemy.Repo.Migrations.RenameIdentityTable do
  use Ecto.Migration

  def change do
    rename table("identities"), to: table("users")
  end
end
