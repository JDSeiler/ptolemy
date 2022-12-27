defmodule Ptolemy.Controllers.Auth.Create do
  use Plug.Builder

  import Logger
  import Ptolemy.Helpers.Validators, only: [validate_body_params: 2]
  alias Ptolemy.Helpers.Responses, as: Resp

  alias Ptolemy.Schemas.User, as: User
  alias Ptolemy.Schemas.VerificationCode, as: VerificationCode

  plug(Plug.Parsers, parsers: [:json], json_decoder: Jason)
  plug(:validate_body_params, ["email", "username", "password"])
  plug(:reject_empty_params)
  plug(:handle_request)

  def handle_request(conn, _opts) do
    # assigned by `validate_body_params`
    params = conn.assigns[:validated_body_params]
    reject_empty_params(conn, params)
    salt = Base.encode64(:crypto.strong_rand_bytes(16))
    # The hash just produces a bunch of bytes, base64 encoding them makes sure that
    # they can be easily represented in the database.
    hashed_password = Base.encode64(:crypto.hash(:sha256, "#{params["password"]}:#{salt}"))

    new_user =
      User.changeset(%User{}, %{
        email: params["email"],
        username: params["username"],
        password: hashed_password,
        salt: salt,
        email_verification_status: "pending"
      })

    with {:ok, user} <- Ptolemy.Repo.insert(new_user) do
      verification_code = Base.url_encode64(:crypto.strong_rand_bytes(64))

      set_verification_code(user.email, verification_code)

      if Application.get_env(:ptolemy, :enable_mailer) == "true" do
        case send_verification_email(user, verification_code) do
          :ok -> debug("Email sent successfully")
          {:error, msg} -> Resp.error(msg)
        end
      else
        debug("Verification code for email: #{user.email} is #{verification_code}")
      end

      send_resp(conn, 201, Resp.information("Created"))
    else
      {:error, changeset} ->
        # Warning to self: Their could be errors for OTHER reasons, but I am
        # naively pretending that if there's an error, it's because of a violation
        # of the unique index on email or username.
        duplicate_fields = Enum.map(changeset.errors, fn {key, {_msg, _details}} ->
          key
        end)

        Plug.Conn.put_resp_header(conn, "content-type", "application/json")
        |> send_resp(
            422,
            Resp.error("DuplicateFields", %{fields: duplicate_fields})
          )
    end
  end

  # Private Functions

  defp set_verification_code(email, verification_code) do
    Ptolemy.Repo.insert(%VerificationCode{email: email, code: verification_code})

    # Current time in seconds since the Epoch
    # now = DateTime.utc_now() |> DateTime.to_unix()
    # Add 12 hours in seconds
    # expires_at = now + 43200

    # I COULD store an "expires_at" time with the key.
    # But I don't want to deal with having to resend emails.
    # So for now, verification keys will stay valid forever.
  end

  defp send_verification_email(user, verification_code) do
    subject = "Verify your email"

    query_params = %{"email" => user.email, "code" => verification_code}
    encoded_query_params = URI.encode_query(query_params)

    html_body =
      "Please verify your email by visiting the following link: <a href=\"http://localhost:4001?#{encoded_query_params}\">Click to verify</a>"

    recipients = [
      %{
        Email: user.email,
        Name: user.username
      }
    ]

    Ptolemy.Services.Mailer.send_email(subject, html_body, recipients)
  end

  # TODO: Eventually I'd like to wrap this functionality into the validators
  # but doing it properly would take more effort than I wont to expend right now.
  defp reject_empty_params(conn, _opts) do
    alias Plug.Conn

    params = conn.assigns[:validated_body_params]

    Map.keys(params)
    |> Enum.reduce_while(conn, fn k, acc ->
      if String.length(params[k]) == 0 do
        {:halt, Conn.halt(Conn.send_resp(conn, 422, "Required parameter `#{k}` cannot be blank"))}
      else
        {:cont, acc}
      end
    end)
  end
end
