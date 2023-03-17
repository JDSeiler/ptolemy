defmodule Ptolemy.Routes.Agencies do
  alias Ptolemy.Controllers.Agencies
  use Plug.Router

  plug :match
  plug :dispatch

  get "/", to: Agencies.Index
  get "/:id", to: Agencies.Show
  post "/", to: Agencies.Create
  patch "/:id", to: Agencies.Edit
  delete "/:id", to: Agencies.Destroy
end
