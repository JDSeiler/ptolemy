defmodule Ptolemy.Controllers.Auth.Verify do
  use Plug.Builder
  alias Ptolemy.Schemas.User, as: User
  alias Ptolemy.Schemas.VerificationCode, as: VerificationCode
  import Ptolemy.Helpers.Validators, only: [validate_query_params: 2]

  plug(:validate_query_params, ["email", "code"])
  plug(:handle_request)

  def handle_request(conn, _opts) do
    # assigned by `validate_query_params
    params = conn.assigns[:validated_query_params]

    with {:ok, verification_entry} <- lookup_code(params["email"]) do
      if verification_entry.code == params["code"] do
        user = Ptolemy.Repo.get_by(User, email: params["email"])
        user = Ecto.Changeset.change(user, %{email_verification_status: "verified"})

        case Ptolemy.Repo.update(user) do
          {:ok, _} ->
            Ptolemy.Repo.delete(verification_entry)
            halt send_resp(conn, 204, "")
          {:error, changeset} ->
            IO.inspect changeset.errors
            halt send_resp(conn, 422, "Could not update verification status in the database")
        end
      else
        halt send_resp(conn, 422, "Provided code does not match stored code for #{params["email"]}")
      end
    else
      :error -> halt send_resp(conn, 422, "No verification code found for #{params["email"]}")
    end
  end

  defp lookup_code(associated_email) do
    case Ptolemy.Repo.get_by(VerificationCode, email: associated_email) do
      nil -> :error
      vc -> {:ok, vc}
    end
  end
end
