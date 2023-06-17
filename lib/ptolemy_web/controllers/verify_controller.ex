defmodule PtolemyWeb.VerifyController do
  use PtolemyWeb, :controller

  def index(conn, %{"code" => code}) do
    text(conn, "Extracted query parameter #{code}")
  end

  def index(conn, _params) do
    conn |> resp(404, "Not found") |> send_resp()
  end
end
