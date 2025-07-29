defmodule Demo.Application do
  @moduledoc """
  Demo application that uses the Elli HTTP server.
  """
  
  use Application
  
  def start(_type, _args) do
    children = [
      # Start the Elli supervision tree
      {Elli.ServerSupervisor, []}
    ]
    
    opts = [strategy: :one_for_one, name: Demo.Supervisor]
    
    case Supervisor.start_link(children, opts) do
      {:ok, pid} ->
        # Start the HTTP server after the supervision tree is up
        start_http_server()
        {:ok, pid}
      error ->
        error
    end
  end
  
  defp start_http_server do
    port = System.get_env("PORT", "4000") |> String.to_integer()
    
    Elli.start_server(
      port: port,
      acceptors: 10,
      handler: Demo.RequestHandler
    )
  end
end
