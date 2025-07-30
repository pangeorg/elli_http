defmodule Elli.Application do
  @moduledoc """
  The main application module for Elli HTTP server.

  This sets up the supervision tree and starts the server.
  """

  use Application

  def start(_type, _args) do
    children = [
      {Elli.ServerSupervisor, []}
    ]

    opts = [strategy: :one_for_one, name: Elli.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
