defmodule Server do
  require Logger
  use Application

  def start(_type, _args) do
    children = [
      {Task.Supervisor, name: __MODULE__.TaskSupervisor},
      {Task, fn -> Server.listen() end}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  def listen() do
    case :gen_tcp.listen(4221, [:binary, active: false, reuseaddr: true]) do
      {:ok, socket} -> accept(socket)
      {:error, _} -> Logger.error("Error: Could not bind to port 4211")
    end
  end

  def accept(socket) do
    case :gen_tcp.accept(socket) do
      {:ok, client} ->
        {:ok, _} = Task.Supervisor.start_child(Server.TaskSupervisor, fn -> serve(client) end)

      {:error, reason} ->
        Logger.error(reason)
    end

    accept(socket)
  end

  defp serve(socket) do
    {:ok, data} = :gen_tcp.recv(socket, 0)

    parse_request(data)

    :gen_tcp.send(socket, "HTTP/1.1 200 OK\r\n\r\n")
    :gen_tcp.close(socket)
    :ok
  end

  defp parse_request(request) do
    case HttpRequestParser.parse(request) do
      {:ok, parsed} -> IO.puts(HttpRequestSerializer.to_string(parsed))
    end
  end
end

defmodule HttpRequest do
  @type t :: %__MODULE__{
          method: String.t(),
          path: String.t(),
          version: String.t(),
          headers: map(),
          body: String.t()
        }
  @enforce_keys [:method, :path, :version]
  defstruct [:method, :path, :version, headers: %{}, body: ""]
end

defmodule HttpResponse do
  @type t :: %__MODULE__{
          version: String.t(),
          status: integer(),
          headers: map(),
          body: String.t()
        }
  defstruct [:version, :status, headers: %{}, body: ""]
end

defmodule HttpRequestSerializer do
  @spec to_string(HttpRequest.t()) :: String.t()
  def to_string(%HttpRequest{} = request) do
    [
      build_start_line(request),
      build_headers(request.headers),
      "\r\n",
      request.body
    ]
    |> Enum.join()
  end

  defp build_start_line(%{method: method, path: path, version: version}) do
    "#{method} #{path} HTTP/#{version}\r\n"
  end

  defp build_headers(headers) when is_map(headers) do
    headers
    |> Enum.map(fn {name, value} -> "#{name}: #{value}\r\n" end)
    |> Enum.join()
  end
end

defmodule HttpRequestParser do
  require HttpRequest

  @spec parse(String.t()) :: {:ok, httpRequest} | {:error, reason}
        when reason: String.t(),
             httpRequest: HttpRequest.t()
  def parse(request) do
    with {:ok, lines} <- split_lines(request),
         {:ok, start_line, remaining_lines} <- parse_start_line(lines),
         {:ok, headers, remaining_lines} <- parse_headers(remaining_lines),
         {:ok, body} <- parse_body(remaining_lines) do
      {:ok,
       %HttpRequest{
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

defmodule CLI do
  def main(_args) do
    # Start the Server application
    {:ok, _pid} = Application.ensure_all_started(:codecrafters_http_server)

    # Run forever
    Process.sleep(:infinity)
  end
end
