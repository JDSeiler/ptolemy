defmodule Ptolemy.Repo.Migrations.AddUniqueConstraintsToUsers do
  use Ecto.Migration

  def change do
    create index("users", [:email, :username], unique: true)
  end
end
