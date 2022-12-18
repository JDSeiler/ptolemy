defmodule Ptolemy.Services.Mailer do
  @typedoc """
  An intended recipient of an email
  """
  @type recipient :: %{ Email: String.t, Name: String.t }

  @callback send_email(subject :: String.t, html_body :: String.t, recipients :: nonempty_list(recipient)) :: :ok | {:error, String.t}

  @spec send_email(
          subject :: String.t(),
          html_body :: String.t(),
          recipients :: nonempty_list(Mailer.recipient())
        ) :: :ok | {:error, String.t()}
  def send_email(subject, html_body, recipients), do: impl().send_email(subject, html_body, recipients)
  defp impl, do: Application.get_env(:ptolemy, :mailer, Ptolemy.Services.MailJetMailer)
end
