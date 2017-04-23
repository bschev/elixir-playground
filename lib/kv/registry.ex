defmodule KV.Registry do
  use GenServer

  ## Client API

  @doc """
  Starts the registry.
  """
  def start_link do
    # Start a new GenServer for the current module (= __MODULE__).
    # The initialization argument :ok matches the argument to init/1.
    GenServer.start_link(__MODULE__, :ok, [])
  end

  @doc """
  Looks up the bucket pid for `name` stored in `server`.

  Returns `{:ok, pid}` if the bucket exists, `:error` otherwise.
  """
  def lookup(server, name) do
    # Calls are synchronous and the server must send a response back to such requests.
    # The requests must match the first argument to handle_call/3.
    GenServer.call(server, {:lookup, name})
  end

  @doc """
  Ensures there is a bucket associated to the given `name` in `server`.
  """
  def create(server, name) do
    # Casts are asynchronous and the server won’t send a response back.
    # The requests must match the first argument to handle_cast/2.
    GenServer.cast(server, {:create, name})
  end

  ## Server Callbacks

  def init(:ok) do
    # Receives the second argument given to GenServer.start_link/3 and returns
    # {:ok, state}, where state contains two maps, one that contains name -> pid
    # and another that holds ref -> name
    {:ok, %{}}
    names = %{}
    refs  = %{}
    {:ok, {names, refs}}
  end

  def handle_call({:lookup, name}, _from, {names, _} = state) do
    # Receives the request, the process from which we received the request (_from),
    # and the current server state (names).
    # Returns a tuple in the format {:reply, reply, new_state}.
    # reply, is what will be sent to the client
    {:reply, Map.fetch(names, name), state}
  end

  def handle_cast({:create, name}, {names, refs}) do
    # Receives the request and the current server state.
    # Returns a tuple in the format {:noreply, new_state}.
    # (Only for illustration of cast callback, real implementation would probably
    # be synchronous, a cast does not even guarantee the server has received the message.)
    if Map.has_key?(names, name) do
      {:noreply, {names, refs}}
    else
      # This is a bad idea, as we don’t want the registry to crash when a bucket crashes!
      {:ok, pid} = KV.Bucket.start_link
      # Monitor each bucket. Process.monitor(pid) returns a unique reference
      # that allows us to match upcoming messages to that monitoring reference.
      ref = Process.monitor(pid)
      refs = Map.put(refs, ref, name)
      names = Map.put(names, name, pid)
      {:noreply, {names, refs}}
    end
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
    # Receives the monitoring :DOWN message containing the exact reference returned
    # by monitor and the bucket process after a bucket agent stoped.
    # Receives the current server state as sewcond argument.
    # Clean up the dictionaries in order to avoid serving stale entries.
    {name, refs} = Map.pop(refs, ref)
    names = Map.delete(names, name)
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
