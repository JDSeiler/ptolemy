defmodule Ptolemy.RootRouter do
  use Plug.Router

  plug(Plug.Logger)
  plug(:put_secret_key_base)

  plug(Plug.Session,
    store: :cookie,
    key: "_ptolemy",
    http_only: true,
    # TODO: use Secure attribute on the cookie
    # I can only set up the Secure attribute once Ptolemy is being
    # accessed via HTTPS
    # Setting `encryption_salt` to nil (the default) turns of encryption.
    # Is encryption even doing anything for me here aside from making
    # the code "feel cooler" because it's encrypted? That and taking
    # up CPU cycles?
    encryption_salt: Application.compile_env(:ptolemy, :encryption_salt),
    signing_salt: Application.compile_env(:ptolemy, :signing_salt),
    log: :debug
  )
  # For now, only configure CORS to accept requests from my local WebPack
  # server. A production deployment will make this more complicated, but
  # we can keep it simple for now.
  plug(CORSPlug, origin: ["http://localhost:3000"])

  # The order of the plugs here is important because we need CORSPlug
  # to intercept OPTIONS requests, which are otherwise undefined.
  plug(:match)
  plug(:dispatch)

  if Mix.env() == :dev do
    use Plug.Debugger
  end

  use Plug.ErrorHandler


  forward("/auth", to: Ptolemy.Routes.Auth)

  # Ripped straight from the Plug.Router docs
  @impl Plug.ErrorHandler
  def handle_errors(conn, %{kind: kind, reason: reason, stack: stack}) do
    encode_result =
      Jason.encode(%{
        debug: %{
          kind: kind,
          reason: reason,
          stack: stack
        }
      })

    case encode_result do
      {:ok, json_string} ->
        send_resp(conn, 500, json_string)

      _ ->
        send_resp(
          conn,
          500,
          "Something went wrong, but the error information failed to encode to JSON."
        )
    end
  end

  # This is pulled from the Plug.Session.COOKIE docs
  defp put_secret_key_base(conn, _) do
    put_in(conn.secret_key_base, Application.get_env(:ptolemy, :secret_key_base))
  end
end
