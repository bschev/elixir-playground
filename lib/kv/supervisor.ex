defmodule KV.Supervisor do
  use Supervisor

  def start_link do
    # Start a new Supervisor for the current module (= __MODULE__).
    # The initialization argument :ok matches the argument to init/1.
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    # The supervisor is going to start the child processes
    # - KV.Registry.start_link(KV.Registry)
    # - KV.Bucket.Supervisor.start_link()
    children = [
      worker(KV.Registry, [KV.Registry]),
      supervisor(KV.Bucket.Supervisor, [])
    ]

    # The supervision strategy dictates what happens when one of the children crashes.
    # 'rest_for_one' means if the registry worker crashes, both the registry and
    # the “rest” of KV.Supervisor’s children (i.e. KV.Bucket.Supervisor) will be restarted.
    # However, if KV.Bucket.Supervisor crashes, KV.Registry will not be restarted,
    # because it was started prior to KV.Bucket.Supervisor.
    supervise(children, strategy: :rest_for_one)
  end
end
