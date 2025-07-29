defmodule Elli.AcceptorSupervisor do
  @moduledoc """
  Dynamic supervisor for acceptor processes.

  This supervisor manages the acceptor processes that handle incoming connections.
  """

  use DynamicSupervisor

  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_acceptor(server_state) do
    child_spec = %{
      id: Elli.Acceptor,
      start: {Elli.Acceptor, :start_link, [server_state]},
      restart: :permanent,
      type: :worker
    }

    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  def stop_all_acceptors do
    DynamicSupervisor.which_children(__MODULE__)
    |> Enum.each(fn {_, pid, _, _} ->
      DynamicSupervisor.terminate_child(__MODULE__, pid)
    end)
  end
end
