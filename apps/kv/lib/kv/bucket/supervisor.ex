defmodule KV.Bucket.Supervisor do
  use Supervisor

  # A simple module attribute that stores the supervisor name
  @name KV.Bucket.Supervisor

  def start_link do
    # Start a new Supervisor for the current module (= __MODULE__).
    # The initialization argument :ok matches the argument to init/1.
    Supervisor.start_link(__MODULE__, :ok, name: @name)
  end

  def start_bucket do
    # Start a bucket as a child of our supervisor named KV.Bucket.Supervisor.
    Supervisor.start_child(@name, [])
  end

  def init(:ok) do
    # Make the worker :temporary. This means that if the bucket dies, it won’t be restarted.
    # That’s because we only want to use the supervisor as a mechanism to group the buckets.
    children = [
      worker(KV.Bucket, [], restart: :temporary)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
