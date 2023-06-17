defmodule PtolemyWeb.AgencyHTML do
  use PtolemyWeb, :html

  embed_templates "agency_html/*"

  @doc """
  Renders a agency form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def agency_form(assigns)
end
