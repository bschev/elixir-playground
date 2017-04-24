defmodule KV do
    use Application
  @moduledoc """
  Documentation for KV.
  """

  @doc """
  """
  def start(_type, _args) do
    KV.Supervisor.start_link
  end
end
