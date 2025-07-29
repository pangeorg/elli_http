defmodule Elli.Acceptor do
  @moduledoc """
  Individual acceptor process that handles incoming connections.

  Each acceptor runs in its own process under the AcceptorSupervisor.
  """

  use GenServer
  require Logger

  def start_link(server_state) do
    GenServer.start_link(__MODULE__, server_state)
  end

  @impl true
  def init(server_state) do
    # Start accepting connections immediately
    send(self(), :accept)
    {:ok, server_state}
  end

  @impl true
  def handle_info(:accept, state) do
    case :gen_tcp.accept(state.listen_socket) do
      {:ok, client_socket} ->
        # Handle the connection in a separate process
        Task.start(fn ->
          Elli.Server.handle_connection(client_socket, state.handler)
        end)

        # Continue accepting
        send(self(), :accept)
        {:noreply, state}

      {:error, :closed} ->
        # Server socket was closed, exit gracefully
        {:stop, :normal, state}

      {:error, reason} ->
        Logger.error("Accept error: #{inspect(reason)}")
        # Brief pause before retrying
        Process.send_after(self(), :accept, 100)
        {:noreply, state}
    end
  end
end
