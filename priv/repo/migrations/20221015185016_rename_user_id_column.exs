defmodule Ptolemy.Repo.Migrations.RenameUserIdColumn do
  use Ecto.Migration

  def change do
    rename table("users"), :user_id, to: :id
  end
end
