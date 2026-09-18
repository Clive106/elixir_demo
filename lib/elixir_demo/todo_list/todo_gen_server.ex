defmodule TodoGenServer do
  use GenServer
  def start() do
    GenServer.start(__MODULE__, nil)
  end

  def init(_) do
    {:ok, TodoList.new()}
  end

  def handle_call({:entries, date},_, todo_list) do
    {:reply, TodoList.entries(todo_list, date), todo_list}
  end

  def handle_cast({:add_entry, new_entry}, todo_list) do
    {:noreply, TodoList.add_entry(todo_list, new_entry)}
  end

  def handle_cast({:update_entry, entry_id, updater_fun}, todo_list) do
    {:noreply, TodoList.update_entry(todo_list, entry_id, updater_fun)}
  end

  def handle_cast({:delete_entry, entry_id}, todo_list) do
    {:noreply, TodoList.delete_entry(todo_list, entry_id)}
  end

  def add_entry(server_pid, new_entry) do
    GenServer.cast(server_pid, {:add_entry, new_entry})
  end

  def entries(server_pid, date) do
    GenServer.call(server_pid , {:entries, date})
  end

  def update_entry(server_pid, entry_id, updater_fun) do
    GenServer.cast(server_pid, {:update_entry, entry_id, updater_fun})
  end

  def delete_entry(server_pid, entry_id) do
    GenServer.cast(server_pid, {:delete_entry, entry_id})
  end
end
