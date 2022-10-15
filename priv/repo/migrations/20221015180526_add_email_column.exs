defmodule Ptolemy.Repo.Migrations.AddEmailColumn do
  use Ecto.Migration

  def change do
    alter table("users") do
      add :email, :text
    end
  end
end
