defmodule Ptolemy.Controllers.Auth.Verify do
  use Plug.Builder
  alias Ptolemy.Schemas.User, as: User
  alias Ptolemy.Schemas.VerificationCode, as: VerificationCode
  import Ptolemy.Helpers.Validators, only: [validate_query_params: 2]
  import Ptolemy.Helpers.Responses

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

            send_resp(conn, 204, "")
            |> halt()

          {:error, changeset} ->
            IO.inspect(changeset.errors)

            put_resp_header(conn, "content-type", "application/json")
            |> send_resp(
              500,
              information("Internal Server Error", [
                "Could not update verification status in the database"
              ])
            )
            |> halt()
        end
      else
        put_resp_header(conn, "content-type", "application/json")
        |> send_resp(
          422,
          information("Unprocessable Entity", ["Provided code is invalid"])
        )
        |> halt()
      end
    else
      :error ->
        put_resp_header(conn, "content-type", "application/json")
        |> send_resp(422, information("Unprocessable Entity", ["Provided code is invalid"]))
        |> halt()
    end
  end

  defp lookup_code(associated_email) do
    case Ptolemy.Repo.get_by(VerificationCode, email: associated_email) do
      nil -> :error
      vc -> {:ok, vc}
    end
  end
end
