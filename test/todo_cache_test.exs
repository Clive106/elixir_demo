defmodule TodoCacheTest do
  use ExUnit.Case
  test "server_process" do
    {:ok, cache_pid} = TodoCache.start()
    bob_pid = TodoCache.server_process(cache_pid, "bob")

    assert bob_pid != TodoCache.server_process(cache_pid, "clive")
    assert bob_pid == TodoCache.server_process(cache_pid, "bob")

  end

  test "todo operations" do
    {:ok, cache} = TodoCache.start()
    alice = TodoCache.server_process(cache, "alice")

    TodoGenServer.add_entry(alice, %{date: ~D[2024-06-01], title: "Buy milk"})
    entries = TodoGenServer.entries(alice, ~D[2024-06-01])
    assert [%{date: ~D[2024-06-01], title: "Buy milk"}] = entries
  end
end
