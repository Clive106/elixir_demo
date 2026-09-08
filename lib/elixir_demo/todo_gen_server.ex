defmodule TodoGenServer do
  def start() do
    ServerProcess.start(TodoGenServer)
  end

  def init() do
    TodoList.new()
  end

  def handle_call({:entries, date}, todo_list) do
    {TodoList.entries(todo_list, date), todo_list}
  end

  def handle_cast({:add_entry, new_entry}, todo_list) do
    TodoList.add_entry(todo_list, new_entry)
  end

  def handle_cast({:update_entry, entry_id, updater_fun}, todo_list) do
    TodoList.update_entry(todo_list, entry_id, updater_fun)
  end

  def handle_cast({:delete_entry, entry_id}, todo_list) do
    TodoList.delete_entry(todo_list, entry_id)
  end

  def add_entry(server_pid, new_entry) do
    ServerProcess.cast(server_pid, {:add_entry, new_entry})
  end

  def entries(server_pid, date) do
    ServerProcess.call(server_pid, {:entries, date})
  end

  def update_entry(server_pid, entry_id, updater_fun) do
    ServerProcess.cast(server_pid, {:update_entry, entry_id, updater_fun})
  end

  def delete_entry(server_pid, entry_id) do
    ServerProcess.cast(server_pid, {:delete_entry, entry_id})
  end
end
