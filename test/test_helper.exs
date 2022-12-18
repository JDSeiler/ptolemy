ExUnit.start()

# Set the connection to the Sandbox to manual mode, so that
# we can manage database connections more finely in tests.
Ecto.Adapters.SQL.Sandbox.mode(Ptolemy.Repo, :manual)
