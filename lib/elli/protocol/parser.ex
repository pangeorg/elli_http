defmodule Elli.Protocol.Parser do
  alias Elli.Protocol.Request, as: Request

  @spec parse_request(String.t()) :: {:ok, httpRequest} | {:error, reason}
        when reason: String.t(),
             httpRequest: Request.t()
  def parse_request(request) do
    with {:ok, lines} <- split_lines(request),
         {:ok, start_line, remaining_lines} <- parse_start_line(lines),
         {:ok, headers, remaining_lines} <- parse_headers(remaining_lines),
         {:ok, body} <- parse_body(remaining_lines) do
      {:ok,
       %Request{
         method: start_line[:method],
         version: start_line[:version],
         path: start_line[:path],
         headers: headers,
         body: body
       }}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @spec split_lines(String.t()) :: {:ok, lines} | {:error, reason}
        when reason: String.t(),
             lines: [String.t()]
  defp split_lines(request) do
    lines = String.split(request, ~r/\r?\n/)

    if length(lines) > 0 do
      {:ok, lines}
    else
      {:error, "Empty request"}
    end
  end

  defp parse_start_line([start_line | remaining]) do
    case String.split(start_line, " ") do
      [method, path, "HTTP/" <> version] ->
        {:ok, %{method: method, path: path, version: version}, remaining}

      _ ->
        {:error, "Could not parse start line of request #{start_line}}"}
    end
  end

  defp parse_start_line([]), do: {:error, "Missing start line"}

  # Parse headers until empty line, return remaining lines
  defp parse_headers(lines, acc \\ %{})
  defp parse_headers(["" | remaining], acc), do: {:ok, acc, remaining}

  defp parse_headers([line | remaining], acc) do
    case String.split(line, ": ", parts: 2) do
      [name, value] ->
        normalized = String.downcase(name)
        parse_headers(remaining, Map.put(acc, normalized, value))

      _ ->
        {:error, "Invalid header format"}
    end
  end

  defp parse_headers([], _acc), do: {:error, "Headers not terminated"}

  # Parse remaining lines as body
  defp parse_body(lines) do
    {:ok, Enum.join(lines, "\n")}
  end
end
