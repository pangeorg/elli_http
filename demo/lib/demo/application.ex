defmodule Demo.Application do
  @moduledoc """
  Demo application that uses the Elli HTTP server.
  """
  
  use Application
  
  def start(_type, _args) do
    port = System.get_env("PORT", "4000") |> String.to_integer()
    children = [
      # Start the Elli supervision tree
      {Elli.ServerSupervisor, [
        port: port,
        acceptors: 10,
        handler: Demo.RequestHandler
      ]}
    ]
    
    opts = [strategy: :one_for_one, name: Demo.Supervisor]
    
    Supervisor.start_link(children, opts)
  end
end
