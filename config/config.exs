import Config

config :ptolemy,
  ecto_repos: [Ptolemy.Repo],
  mailer: Ptolemy.Services.MailJetMailer,
  enable_mailer: System.get_env("PTOLEMY_ENABLE_MAIL", "true")

config :ptolemy, Ptolemy.Repo,
  database: "ptolemy",
  username: "postgres",
  password: "OVERRIDE ME IN config_secret.exs",
  hostname: "localhost",
  port: "54321"

import_config "config_secret.exs"
