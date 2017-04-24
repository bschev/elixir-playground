defmodule KV.Registry do
  use GenServer

  ## Client API

  @doc """
  Starts the registry with the given `name`.
  """
  def start_link(name) do
    # Start a new GenServer for the current module (= __MODULE__).
    # Pass the name to init/1.
    GenServer.start_link(__MODULE__, name, name: name)
  end

  @doc """
  Looks up the bucket pid for `name` stored in `server`.

  Returns `{:ok, pid}` if the bucket exists, `:error` otherwise.
  """
  def lookup(server, name) when is_atom(server) do
    # Lookup bucket in ETS, without accessing the server
    case :ets.lookup(server, name) do
      [{^name, pid}] -> {:ok, pid}
      [] -> :error
    end
  end

  @doc """
  Ensures there is a bucket associated to the given `name` in `server`.
  """
  def create(server, name) do
    # Calls are synchronous and the server must send a response back to such requests.
    # The requests must match the first argument to handle_call/3.
    GenServer.call(server, {:create, name})
  end

  @doc """
  Stops the registry.
  """
  def stop(server) do
    GenServer.stop(server)
  end

  ## Server Callbacks

  def init(table) do
    # Receives the second argument given to GenServer.start_link/3 and returns
    # {:ok, state}, where state contains a ETS table for name -> pid
    # and a map that holds ref -> name
    names = :ets.new(table, [:named_table, read_concurrency: true])
    refs  = %{}
    {:ok, {names, refs}}
  end

  def handle_call({:create, name}, _from, {names, refs}) do
    # Receives the request, the process from which we received the request (_from),
    # and the current server state (names, refs).
    # Returns a tuple in the format {:reply, reply, new_state}.
    # reply, is what will be sent to the client
    case lookup(names, name) do
      {:ok, pid} ->
        {:reply, pid, {names, refs}}
      :error ->
        {:ok, pid} = KV.Bucket.Supervisor.start_bucket
        ref = Process.monitor(pid)
        refs = Map.put(refs, ref, name)
        :ets.insert(names, {name, pid})
        {:reply, pid, {names, refs}}
    end
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
    # Receives the monitoring :DOWN message containing the exact reference returned
    # by monitor and the bucket process after a bucket agent stoped.
    # Receives the current server state as second argument.
    # Clean up map and ETS table in order to avoid serving stale entries.
    {name, refs} = Map.pop(refs, ref)
    :ets.delete(names, name)
    {:noreply, {names, refs}}
  end

  def handle_info(_msg, state) do
    # “catch-all” clause that discards any unknown message.
    # Since any message, including the ones sent via send/2, go to handle_info/2,
    # there is a chance unexpected messages will arrive to the server. Therefore,
    # if we don’t define this catch-all clause, those messages could lead our
    # registry to crash, because no clause would match.
    {:noreply, state}
  end
end
