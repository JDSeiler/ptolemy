defmodule Ptolemy.Token do
  use Joken.Config

  @impl true
  def token_config do
    default_claims(iss: "Ptolemy", aud: "Ptolemy")
    |> add_claim("sub", nil, &(is_binary(&1)))
    # TODO: Validate that the sub is an actual user in the database?
  end
end
