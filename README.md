# Ptolemy

- `mix deps.get` to install dependencies
- Copy `.env.sample` to `.env` and fill in your desired Postgres password.
- Copy `config/config_secret.exs.template` to `config/config_secret.exs` and
  add the same password.
- `docker-compose up` to start the Postgres server and Adminer
- `mix run --no-halt` to start the web server

## Ecto Cookbook
TODO

## TODO

1. Get Ecto up and running
2. Get a JSON parsing example working (JSON request body and JSON response)
3. Get a JWT example working
    - Create a signed JWT and send it to the client
    - Write a plug to validate JWTs sent in the Authorization header.
4. Set up email sending with SendGrid or somethin'
5. Write full auth flow?!?