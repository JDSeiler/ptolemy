defmodule Ptolemy.Routes.Auth do
  alias Ptolemy.Controllers.Auth, as: Auth
  use Plug.Router

  plug Plug.Logger
  plug :match
  plug :dispatch

  post "/create", to: Auth.Create

  post "/verify" do

  end

  post "/login" do

  end

  post "/refresh" do

  end
end
