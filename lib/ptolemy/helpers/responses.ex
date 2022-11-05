defmodule Ptolemy.Helpers.Responses do
  def information(message, details) do
    {:ok, json_string} =
      Jason.encode(%{
        message: message,
        details: details
      })

    json_string
  end

  def information(message) do
    information(message, [])
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
