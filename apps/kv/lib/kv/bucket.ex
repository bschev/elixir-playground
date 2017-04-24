defmodule KV.Bucket do
  @doc """
  Starts a new bucket.
  """
  def start_link do
    # Starts an agent linked to the current process. Once the agent is spawned,
    # the given function is invoked and the returned map is used as the agent state.
    Agent.start_link(fn -> %{} end)
  end

  @doc """
  Gets a value from the `bucket` by `key`.
  """
  def get(bucket, key) do
    # The function &Map.get/2 is sent to the agent which invokes the function
    # passing the agent state. The result of the function invocation is returned.
    # Everything that is inside the function we passed to the agent happens in
    # the agent process. We say the agent process is the server, everything outside
    # the function is happening in the client.
    Agent.get(bucket, &Map.get(&1, key))
  end

  @doc """
  Puts the `value` for the given `key` in the `bucket`.
  """
  def put(bucket, key, value) do
    Agent.update(bucket, &Map.put(&1, key, value))
  end

  @doc """
  Deletes `key` from `bucket`.

  Returns the current value of `key`, if `key` exists.
  """
  def delete(bucket, key) do
    Agent.get_and_update(bucket, &Map.pop(&1, key))
  end

end
