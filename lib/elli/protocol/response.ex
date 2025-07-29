defmodule Elli.Protocol.Response do
  alias Elli.Protocol.Response

  @type t :: %__MODULE__{
          version: String.t(),
          status: integer(),
          headers: map(),
          body: String.t()
        }
  defstruct [:version, :status, headers: %{}, body: ""]

  @spec internal_server_error(String.t()) :: Response.t()
  def internal_server_error(body) do
    %Response{version: "1.1", status: 500, body: body}
  end

  @spec bad_request(String.t()) :: Response.t()
  def bad_request(body) do
    %Response{version: "1.1", status: 400, body: body}
  end

  @spec not_found(String.t()) :: Response.t()
  def not_found(body) do
    %Response{version: "1.1", status: 404, body: body}
  end

  @spec ok(String.t()) :: Response.t()
  def ok(body) do
    %Response{version: "1.1", status: 200, body: body}
  end

  @spec ok(String.t(), map()) :: Response.t()
  def ok(body, headers) do
    %Response{version: "1.1", status: 200, body: body, headers: headers}
  end

  @spec json(map()) :: Response.t()
  def json(data, headers \\ %{}) when is_map(data) and is_map(headers) do
    ok(JSON.encode!(data), headers)
  end
end
