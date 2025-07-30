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
  def init(opts) do
    children = [
      {Elli.AcceptorSupervisor, []},
      # Start the server with the provided config
      {Elli.Server, opts}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  @doc """
  Starts a server with the given configuration.
  ## Example
    # Start additional servers on different ports
    Elli.start_server(port: 3000, handler: APIHandler)
    Elli.start_server(port: 4000, handler: WebHandler)

    # Start server manually in IEx for testing
    iex> Elli.start_server(handler: TestHandler)
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
