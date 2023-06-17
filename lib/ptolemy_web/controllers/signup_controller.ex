defmodule PtolemyWeb.SignupController do
  use PtolemyWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end
end
