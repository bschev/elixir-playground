defmodule KV.RouterTest do
  use ExUnit.Case, async: true

  # In order to run this test, we need to have two nodes running.
  # apps/kv$ iex --sname bar -S mix
  # apps/kv$ elixir --sname foo -S mix test
  @tag :distributed
  test "route requests across nodes" do
    # Invoke Kernel.node/0 and check that it returns the name of the correct node.
    {:ok, hostname} = :inet.gethostname
    assert KV.Router.route("hello", Kernel, :node, []) ==
           :"foo@#{hostname}"
    assert KV.Router.route("world", Kernel, :node, []) ==
           :"bar@#{hostname}"
  end

  test "raises on unknown entries" do
    assert_raise RuntimeError, ~r/could not find entry/, fn ->
      KV.Router.route(<<0>>, Kernel, :node, [])
    end
  end
end
