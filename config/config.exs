import Config

config :ptolemy, ecto_repos: [Ptolemy.Repo]

config :ptolemy, Ptolemy.Repo,
  database: "ptolemy",
  username: "postgres",
  password: "OVERRIDE ME IN config_secret.exs",
  hostname: "localhost",
  port: "54321"

import_config "config_secret.exs"
