defmodule KVServer.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    port = Application.fetch_env!(:kv_server, :port)

    # Start a Task.Supervisor process with name KVServer.TaskSupervisor.
    # Run KVServer.accept(port) as a worker.
    children = [
      supervisor(Task.Supervisor, [[name: KVServer.TaskSupervisor]]),
      worker(Task, [KVServer, :accept, [port]])
    ]

    # Define inline supervisor.
    opts = [strategy: :one_for_one, name: KVServer.Supervisor]
    Supervisor.start_link(children, opts)
  end

end
