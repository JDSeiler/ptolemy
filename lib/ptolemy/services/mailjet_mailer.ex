defmodule Ptolemy.Services.MailJetMailer do
  alias Ptolemy.Services.Mailer, as: Mailer
  @behaviour Mailer

  @impl Mailer
  @spec send_email(
          subject :: String.t(),
          html_body :: String.t(),
          recipients :: nonempty_list(Mailer.recipient())
        ) :: :ok | {:error, String.t()}
  def send_email(subject, html_body, recipients) do
    mailjet_config = Application.get_env(:ptolemy, MailJet)
    api_key = Keyword.get(mailjet_config, :api_key)
    api_secret = Keyword.get(mailjet_config, :api_secret)
    authorization_header = "Basic #{Base.encode64("#{api_key}:#{api_secret}")}"

    {:ok, request_body} =
      Jason.encode(%{
        FromEmail: "learn1reactbase@gmail.com",
        FromName: "Ptolemy",
        Recipients: recipients,
        Subject: subject,
        "Html-Part": html_body
      })

    # See: https://elixirforum.com/t/httpc-cheatsheet/50337
    url = 'https://api.mailjet.com/v3/send'
    headers = [{'authorization', to_charlist(authorization_header)}]
    content_type = 'application/json'
    body = to_charlist(request_body)

    httpc_options = [
      ssl: [
        verify: :verify_peer,
        cacerts: :public_key.cacerts_get(),
        customize_hostname_check: [
          match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
        ]
      ]
    ]

    {sent_status, result} =
      :httpc.request(
        :post,
        {
          url,
          headers,
          content_type,
          body
        },
        httpc_options,
        []
      )

    case sent_status do
      :ok -> :ok
      :error -> {:error, "email send failed with #{to_string(result)}"}
    end
  end
end
