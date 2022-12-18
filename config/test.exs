import Config

config :ptolemy, Ptolemy.Repo,
  hostname: "localhost",
  port: "54321",
  database: "ptolemy_test",
  username: "postgres",
  password: "OVERRIDE ME IN config_secret.exs",
  pool: Ecto.Adapters.SQL.Sandbox

