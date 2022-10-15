defmodule Ptolemy.Helpers.Validators do
  import Plug.Conn

  def validate_query_params(conn, opts) do
    fetch_query_params(conn)
    result = validate_map(conn.query_params, opts)

    case result do
      {:error, msg} -> halt(send_resp(conn, 422, msg))
      v when is_map(v) -> assign(conn, :validated_query_params, v)
    end
  end

  def validate_body_params(conn, opts) do
    params = conn.body_params
    result = validate_map(params, opts)

    case result do
      {:error, msg} -> halt(send_resp(conn, 422, msg))
      v when is_map(v) -> assign(conn, :validated_body_params, v)
    end
  end

  defp validate_map(map, required_keys) do
    Enum.reduce_while(required_keys, %{}, fn param, acc ->
      case get_field(map, param) do
        {:ok, v} ->
          {:cont, Map.put(acc, param, v)}

        {:not_found, missing_param} ->
          {:halt, {:error, "Required parameter `#{missing_param}` was not found"}}
      end
    end)
  end

  defp get_field(body_params, param_name) do
    case Map.fetch(body_params, param_name) do
      :error -> {:not_found, param_name}
      {:ok, v} -> {:ok, v}
    end
  end
end
