# Ptolemy

Elixir backend for [Alexandria](https://github.com/JDSeiler/alexandria)

- `mix deps.get` to install dependencies
- Copy `.env.sample` to `.env` and fill in your desired Postgres password.
- Copy `config/config_secret.exs.template` to `config/config_secret.exs` and fill in the fields
  - Add your Postgres password to the `Ptolemy.Repo.password` field
  - Use something like `openssl rand -base64` to generate the `secret_key_base`,
    `encryption_salt` and `signing_salt`. The secret_key_base should be at least
    256 bits. Both of the salts may be shorter.
  - Fill out the `Ptolemy.MailJet.api_key` and `Ptolemy.MailJet.api_secret` fields

- `docker-compose up` to start the Postgres server and Adminer
- `mix run --no-halt` to start the web server

## Ecto Cookbook
Docs: 
- https://hexdocs.pm/ecto/Ecto.html
- https://hexdocs.pm/ecto_sql/Ecto.Adapters.SQL.html
    - Contains docs on migrations, constraints, indices, and other SQL
      specific goodies.

Useful commands:
- `mix ecto.gen.repo -r MyProject.Repo` :: Generates repo configuration
- `mix ecto.create` :: Sets up the initial database
- `mix ecto.gen.migration <name>` :: Creates a migration
    - `mix ecto.migrate` :: Run migrations
    - `mix ecto.rollback` :: Rollback migations
    - Both migrate and rollback have extra options to control which migrations to
      run or rollback, such as `--step`, `--to`, etc. See the `ecto_sql` docs.
    - `mix ecto.migrations` :: Show all migrations and their status
