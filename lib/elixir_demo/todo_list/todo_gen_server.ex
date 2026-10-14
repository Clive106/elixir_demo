defmodule TodoGenServer do
  use Agent, restart: :temporary

  def start_link(name) do
    Agent.start_link(
      fn ->
        IO.puts("starting #{name} todo server....")
        {name, TodoDatabase.get(name) || TodoList.new()}
      end,
      name: via_tuple(name)
    )
  end

  defp via_tuple(name) do
    TodoProcessRegistry.via_tuple({__MODULE__, name})
  end

  # interface functions
  def add_entry(server_pid, new_entry) do
    Agent.cast(server_pid, fn {name, todo_list} ->
      new_list = TodoList.add_entry(todo_list, new_entry)
      TodoDatabase.store(name, new_list)
      {name, new_list}
    end)
  end

  def entries(server_pid, date) do
    Agent.get(server_pid, fn {_, todo_list} -> TodoList.entries(todo_list, date) end)
  end

  def update_entry(server_pid, entry_id, updater_fun) do
    Agent.cast(server_pid, fn {name, todo_list} ->
      new_list = TodoList.update_entry(todo_list, entry_id, updater_fun)
      TodoDatabase.store(name, new_list)
      {name, new_list}
    end)
  end

  def delete_entry(server_pid, entry_id) do
    Agent.cast(server_pid, fn {name, todo_list} ->
      new_list = TodoList.delete_entry(todo_list, entry_id)
      TodoDatabase.store(name, new_list)
      {name, new_list}
    end)
  end
end
