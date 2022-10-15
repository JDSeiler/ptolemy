defmodule Ptolemy.Repo.Migrations.AddVerificationCodeTable do
  use Ecto.Migration

  def change do
    create table("verification_codes") do
      add :email, references("users",
        type: :text,
        column: :email,
        on_delete: :delete_all,
        on_update: :update_all
      )
      add :code, :text
    end
  end
end
