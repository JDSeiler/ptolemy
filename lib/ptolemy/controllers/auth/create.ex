defmodule Ptolemy.Controllers.Auth.Create do
  use Plug.Builder
  alias Ptolemy.Schemas.User, as: User
  alias Ptolemy.Schemas.VerificationCode, as: VerificationCode
  import Ptolemy.Helpers.Validators, only: [validate_body_params: 2]
  import Ptolemy.Helpers.Responses

  plug(Plug.Parsers, parsers: [:json], json_decoder: Jason)
  plug(:validate_body_params, ["email", "username", "password"])
  plug(:handle_request)

  def handle_request(conn, _opts) do
    # assigned by `validate_body_params`
    params = conn.assigns[:validated_body_params]
    salt = Base.encode64(:crypto.strong_rand_bytes(16))
    # The hash just produces a bunch of bytes, base64 encoding them makes sure that
    # they can be easily represented in the databse.
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

      # Just print whether the verification email sent or not.
      # TODO: I should send an error response and rollback the insertion
      # if the email fails to send.
      case send_verification_email(user, verification_code) do
        :ok -> IO.puts("Email sent successfully")
        {:error, msg} -> IO.puts(msg)
      end

      IO.puts("Verification code for email: #{user.email} is #{verification_code}")

      send_resp(conn, 201, information("Created"))
    else
      {:error, changeset} ->
        error_list = reformat_errors_for_json(changeset.errors)
        Plug.Conn.put_resp_header(conn, "content-type", "application/json")
        |> send_resp(422, information("Unprocessable Entity", error_list))
    end
  end

  # Private Functions

  defp reformat_errors_for_json(errors) do
    Enum.map(errors, fn {key, {msg, _details}} ->
      "#{key} has the following error: #{msg}"
    end)
  end

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
    mailjet_config = Application.get_env(:ptolemy, MailJet)
    api_key = Keyword.get(mailjet_config, :api_key)
    api_secret = Keyword.get(mailjet_config, :api_secret)
    authorization_header = "Basic #{Base.encode64("#{api_key}:#{api_secret}")}"

    :inets.start()
    # TODO: I'm not actually verifying any SSL certificates.
    # That's bad, and I should do it. But it's not super important right now.
    :ssl.start()

    query_params = %{"email" => user.email, "code" => verification_code}
    encoded_query_params = URI.encode_query(query_params)

    {:ok, request_body} =
      Jason.encode(%{
        FromEmail: "learn1reactbase@gmail.com",
        FromName: "Ptolemy",
        Recipients: [
          %{
            Email: user.email,
            Name: user.username
          }
        ],
        Subject: "Verify your email address",
        "Html-Part":
          "Please verify your email by visting the following link: <a href=\"http://localhost:4001?#{encoded_query_params}\">Click to verify</a>"
      })

    {sent_status, result} =
      :httpc.request(
        :post,
        {
          'https://api.mailjet.com/v3/send',
          [
            {'authorization', to_charlist(authorization_header)}
          ],
          'application/json',
          to_charlist(request_body)
        },
        [],
        []
      )

    case sent_status do
      :ok -> :ok
      :error -> {:error, "email send failed with #{to_string(result)}"}
    end
  end
end
