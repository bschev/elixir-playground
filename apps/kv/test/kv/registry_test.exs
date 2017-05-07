defmodule KV.RegistryTest do
  use ExUnit.Case, async: true

  setup context do
    # context.test is used as a shortcut to spawn a registry
    # with the same name of the test currently running.
    {:ok, _} = KV.Registry.start_link(context.test)
    {:ok, registry: context.test}
  end

  test "spawns buckets", %{registry: registry} do
    assert KV.Registry.lookup(registry, "shopping") == :error

    KV.Registry.create(registry, "shopping")
    assert {:ok, bucket} = KV.Registry.lookup(registry, "shopping")

    KV.Bucket.put(bucket, "milk", 1)
    assert KV.Bucket.get(bucket, "milk") == 1
  end

  test "removes buckets on exit", %{registry: registry} do
    KV.Registry.create(registry, "shopping")
    {:ok, bucket} = KV.Registry.lookup(registry, "shopping")
    Agent.stop(bucket)

    # Do a (synchronous) call to ensure the registry processed the DOWN message.
    # (messages are processed in order)
    _ = KV.Registry.create(registry, "bogus")
    assert KV.Registry.lookup(registry, "shopping") == :error
  end

  test "removes bucket on crash", %{registry: registry} do
    KV.Registry.create(registry, "shopping")
    {:ok, bucket} = KV.Registry.lookup(registry, "shopping")

    # Stop the bucket with non-normal reason
    ref = Process.monitor(bucket)
    Process.exit(bucket, :shutdown)

    # Wait until the bucket is dead
    assert_receive {:DOWN, ^ref, _, _, _}

    # Do a (synchronous) call to ensure the registry processed the DOWN message.
    # (messages are processed in order)
    _ = KV.Registry.create(registry, "bogus")
    assert KV.Registry.lookup(registry, "shopping") == :error
  end
end
