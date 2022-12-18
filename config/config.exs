import Config

config :ptolemy,
  ecto_repos: [Ptolemy.Repo],
  mailer: Ptolemy.Services.MailJetMailer,
  enable_mailer: System.get_env("PTOLEMY_ENABLE_MAIL", "true")

config :ptolemy, Ptolemy.Repo,
  hostname: "localhost",
  port: "54321",
  database: "ptolemy",
  username: "postgres",
  password: "OVERRIDE ME IN config_secret.exs"

# Configs that are imported later merge with (or override, if
# there is a collision) config defined or imported earlier.
import_config "#{Mix.env}.exs"
import_config "config_secret.exs"
