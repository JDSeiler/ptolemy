# Ptolemy

Elixir backend for [Alexandria](https://github.com/JDSeiler/alexandria)

- `mix deps.get` to install dependencies
- Copy `.env.sample` to `.env` and fill in your desired Postgres password.
- Copy `config/config_secret.exs.template` to `config/config_secret.exs` and
  add the same password.
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

## TODO

1. ~~Get Ecto up and running~~ :: DONE
2. Get a JSON parsing example working (JSON request body and JSON response)
3. Get a JWT example working
    - Create a signed JWT and send it to the client
    - Write a plug to validate JWTs sent in the Authorization header.
4. Set up email sending with SendGrid or somethin'
5. Write full auth flow?!?