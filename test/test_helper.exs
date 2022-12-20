ExUnit.start()

# Set the connection to the Sandbox to manual mode, so that
# we can manage database connections more finely in tests.
Ecto.Adapters.SQL.Sandbox.mode(Ptolemy.Repo, :manual)

# Mox
Mox.defmock(Ptolemy.Services.MockMailer, for: Ptolemy.Services.Mailer)
Application.put_env(:ptolemy, :mailer, Ptolemy.Services.MockMailer)
