defmodule Ptolemy.Routes.Auth do
  alias Ptolemy.Controllers.Auth, as: Auth
  use Plug.Router

  plug :match
  plug :dispatch

  post "/create", to: Auth.Create

  post "/verify", to: Auth.Verify

  # post "/login", to: Auth.Login

  # post "/refresh", to: Auth.Refresh
end
