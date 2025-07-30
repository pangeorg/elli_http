defmodule Elli.Server do
  @moduledoc """
  A simple HTTP server implementation using GenServer.

  This server creates a TCP listen socket and spawns acceptor processes
  under supervision to handle incoming connections.
  """

  use GenServer
  require Logger

  @default_port 4000
  @default_acceptors 10

  defstruct [:listen_socket, :port, :acceptors, :handler]

  ## Public API

  @doc """
  Starts the HTTP server.

  ## Options

    * `:port` - The port to listen on (default: 4000)
    * `:acceptors` - Number of acceptor processes (default: 10)
    * `:handler` - Module that implements the request handler callback

  ## Examples

      Elli.Server.start_link(port: 8080, handler: MyApp.Handler)

  """
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  Stops the server gracefully.
  """
  def stop do
    GenServer.stop(__MODULE__)
  end

  @doc """
  Gets the current server status.
  """
  def status do
    GenServer.call(__MODULE__, :status)
  end

  ## GenServer Callbacks

  @impl true
  def init(opts) do
    port = Keyword.get(opts, :port, @default_port)
    acceptors = Keyword.get(opts, :acceptors, @default_acceptors)
    handler = Keyword.get(opts, :handler)

    unless handler do
      raise ArgumentError, "handler module is required"
    end

    # TCP listen options
    listen_opts = [
      :binary,
      packet: :raw,
      active: false,
      reuseaddr: true,
      backlog: 1024
    ]

    case :gen_tcp.listen(port, listen_opts) do
      {:ok, listen_socket} ->
        Logger.info("HTTP server listening on port #{port}")

        state = %__MODULE__{
          listen_socket: listen_socket,
          port: port,
          acceptors: acceptors,
          handler: handler
        }

        # Start acceptor processes under supervision
        start_acceptors(state)

        {:ok, state}

      {:error, reason} ->
        Logger.error("Failed to start server on port #{port}: #{inspect(reason)}")
        {:stop, {:listen_error, reason}}
    end
  end

  @impl true
  def handle_call(:status, _from, state) do
    status = %{
      port: state.port,
      acceptors: state.acceptors,
      handler: state.handler,
      listening: state.listen_socket != nil
    }

    {:reply, status, state}
  end

  @impl true
  def terminate(_reason, state) do
    # Stop all acceptors
    Elli.AcceptorSupervisor.stop_all_acceptors()

    # Close the listen socket
    if state.listen_socket do
      :gen_tcp.close(state.listen_socket)
    end

    :ok
  end

  ## Private Functions

  defp start_acceptors(state) do
    for _i <- 1..state.acceptors do
      {:ok, _pid} = Elli.AcceptorSupervisor.start_acceptor(state)
    end
  end
end
