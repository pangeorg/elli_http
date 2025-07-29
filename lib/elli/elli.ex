defmodule Elli do
  @moduledoc """
  Main interface for the Elli HTTP server.

  Provides convenient functions to start and manage the server.
  """

  @doc """
  Starts the Elli HTTP server with the given options.

  ## Examples

      # Start with default settings
      Elli.start_server(handler: MyApp.Handler)
      
      # Start with custom port and acceptors
      Elli.start_server(
        port: 8080,
        acceptors: 20,
        handler: MyApp.Handler
      )

  """
  def start_server(opts) do
    Elli.ServerSupervisor.start_server(opts)
  end

  @doc """
  Gets the current server status.
  """
  def status do
    Elli.Server.status()
  end

  @doc """
  Stops the server.
  """
  def stop do
    Elli.Server.stop()
  end
end
