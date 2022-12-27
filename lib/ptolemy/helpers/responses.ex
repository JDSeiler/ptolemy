defmodule Ptolemy.Helpers.Responses do
  @spec information(String.t(), list(String.t())) :: binary
  def information(message, details) do
    Jason.encode!(%{
      message: message,
      details: details
    })
  end

  def information(message) do
    information(message, [])
  end

  @spec error(String.t(), map()) :: binary
  def error(kind, details) do
    Jason.encode!(%{
      kind: kind,
      details: details
    })
  end

  def error(kind) do
    error(kind, %{})
  end

  def data(message, data) do
    {:ok, json_string} =
      Jason.encode(%{
        message: message,
        data: data
      })

    json_string
  end
end
