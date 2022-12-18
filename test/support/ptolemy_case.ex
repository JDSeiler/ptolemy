
# This file contains the unit test template all other tests will build on.
# It has two main goals:
# 1. Set up a test environment for Ecto
# 2. (TODO) Set up any global mocks via Mox
defmodule Ptolemy.Case do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias Ptolemy.Repo
      alias Ptolemy.Schemas

      import Ecto
      import Ecto.Query
      import Ptolemy.Case
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Ptolemy.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Ptolemy.Repo, {:shared, self()})
    end

    :ok
  end
end
