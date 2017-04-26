defmodule KVServer do
  @moduledoc """
  Documentation for KVServer.
  """
  require Logger

  def accept(port) do
    # Listen to the port until the socket becomes available.
    # The options below mean:
    #
    # 1. `:binary` - receives data as binaries (instead of lists)
    # 2. `packet: :line` - receives data line by line
    # 3. `active: false` - blocks on `:gen_tcp.recv/2` until data is available
    # 4. `reuseaddr: true` - allows us to reuse the address if the listener crashes
    #
    {:ok, socket} = :gen_tcp.listen(port,
                      [:binary, packet: :line, active: false, reuseaddr: true])
    Logger.info "Accepting connections on port #{port}"
    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    #  For each accepted client connection, we call serve/1.
    {:ok, client} = :gen_tcp.accept(socket)
    # Use Task.Supervisor to serve requests.
    {:ok, pid} = Task.Supervisor.start_child(KVServer.TaskSupervisor, fn -> serve(client) end)
    # Make the child process the “controlling process” of the client socket.
    # If we didn’t do this, the acceptor would bring down all the clients if
    # it crashed because sockets would be tied to the process that accepted them.
    :ok = :gen_tcp.controlling_process(client, pid)
    loop_acceptor(socket)
  end

  defp serve(socket) do
    # The pipe operator evaluates the left side and passes its result as
    # first argument to the function on the right side.
    # Equivalent to: write_line(read_line(socket), socket)
    socket
    |> read_line()
    |> write_line(socket)

    serve(socket)
  end

  defp read_line(socket) do
    {:ok, data} = :gen_tcp.recv(socket, 0)
    data
  end

  defp write_line(line, socket) do
    :gen_tcp.send(socket, line)
  end
end
