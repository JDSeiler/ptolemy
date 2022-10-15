defmodule Ptolemy.Repo.Migrations.SplitUniqeUserIndices do
  use Ecto.Migration

  def change do
    drop index("users", [:email, :username], unique: true)

    create index("users", [:email], unique: true)
    create index("users", [:username], unique: true)
  end
end
