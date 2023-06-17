defmodule Ptolemy.Repo do
  use Ecto.Repo,
    otp_app: :ptolemy,
    adapter: Ecto.Adapters.Postgres

  @tenant_key {__MODULE__, :user_id}

  def put_tenant(user) do
    Process.put(@tenant_key, user)
  end
  def get_tenant do
    Process.get(@tenant_key)
  end
  # TODO: I need to implement multi-tenancy using something like
  # https://hexdocs.pm/ecto/multi-tenancy-with-foreign-keys.html
  # But I need to get a better grasp on Ecto before I start
  # implementing a proper system for it. For now, I think I will
  # implement it manually (add the WHERE for user_id wherever).
  # Basically I'm afraid of borking up the account system since
  # I don't understand it well.
end
