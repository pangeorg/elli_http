defmodule Elli.Protocol.Serializer do
  alias Elli.Protocol.Request, as: Request
  alias Elli.Protocol.Response, as: Response
  alias Elli.Protocol.Request, as: Request

  @spec to_string(Request.t()) :: String.t()
  def to_string(%Request{} = request) do
    [
      build_start_line(request),
      build_headers(request.headers),
      "\r\n",
      request.body
    ]
    |> Enum.join()
  end

  @spec to_string(Response.t()) :: String.t()
  def to_string(%Response{} = response) do
    [
      build_start_line(response),
      build_headers(response.headers),
      "\r\n",
      response.body
    ]
    |> Enum.join()
  end

  defp build_start_line(%{version: version, status: status}) do
    "HTTP/#{version} #{Integer.to_string(status)} \r\n"
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
