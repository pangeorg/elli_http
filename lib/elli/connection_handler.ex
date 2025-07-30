defmodule Elli.ConnectionHandler do
  @moduledoc """
  Dedicated module for handling HTTP connections.

  Separates connection handling logic from both Server and Acceptor.
  """

  require Logger
  alias Elli.Protocol.{Parser, Response, Serializer}

  @doc """
  Handles a single HTTP connection from start to finish.
  """
  def handle_connection(socket, handler) do
    case receive_request(socket) do
      {:ok, request} ->
        try do
          response = handler.handle_request(request)
          send_response(socket, response)
        rescue
          error ->
            Logger.error("Handler error: #{inspect(error)}")
            error_response = Response.internal_server_error("Internal Server Error")
            send_response(socket, error_response)
        end

      {:error, reason} ->
        Logger.warning("Request parsing failed: #{inspect(reason)}")
        error_response = Response.bad_request("Bad Request")
        send_response(socket, error_response)
    end

    :gen_tcp.close(socket)
  end

  defp receive_request(socket) do
    case :gen_tcp.recv(socket, 0, 5000) do
      {:ok, data} -> Parser.parse_request(data)
      {:error, reason} -> {:error, {:recv_error, reason}}
    end
  end

  defp send_response(socket, response) do
    serialized = Serializer.to_string(response)
    :gen_tcp.send(socket, serialized)
  end
end
