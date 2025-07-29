defmodule Elli.ServerSupervisor do
  @moduledoc """
  Supervisor for the HTTP server and its acceptor processes.

  This supervisor manages the main server GenServer and can be configured
  to restart it if it crashes.
  """

  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    children = [
      # Acceptor supervisor for handling connections
      {Elli.AcceptorSupervisor, []}
      # Note: Server will be started dynamically via start_server/1
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  @doc """
  Starts a server with the given configuration.
  """
  def start_server(opts) do
    # The server child spec
    server_spec = {Elli.Server, opts}

    case Supervisor.start_child(__MODULE__, server_spec) do
      {:ok, pid} -> {:ok, pid}
      {:error, {:already_started, pid}} -> {:ok, pid}
      error -> error
    end
  end
end
