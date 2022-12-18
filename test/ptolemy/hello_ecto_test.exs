defmodule Ptolemy.HelloEctoTest do
  use Ptolemy.Case

  test "ecto test environment works" do
    new_user =
      Schemas.User.changeset(%Schemas.User{}, %{
        email: "test@example.com",
        username: "Bob",
        password: "123345",
        salt: "NaCl",
        email_verification_status: "pending"
      })

    assert {:ok, _} = Repo.insert(new_user)
  end
end
