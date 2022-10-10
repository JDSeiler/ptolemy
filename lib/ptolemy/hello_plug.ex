defmodule Ptolemy.HelloPlug do
  use Plug.Router

  # plugs are kinda like Express middleware, but they are more powerful and have more jobs.

  # we can use the `plug` macro to add more plugs, forming a pipeline.
  # first we log, then we match, then we dispatch.
  plug Plug.Logger
  plug :match
  plug :dispatch

  get "/hello/:name" do
    send_resp(conn, 200, "Hello #{name}!")
  end

  # `forward` can be used to compose routers and other plugs.
  # "child plugs" can specify additional plugs that only apply to themselves and their children!
  # For example, SuperSecret uses BasicAuth to protect the secret.
  forward "/secret", to: Ptolemy.SuperSecret

  # functions like get, post, etc. are conceptually just sugar on top of `match`
  match _ do
    send_resp(conn, 404, "not found!")
  end
end
