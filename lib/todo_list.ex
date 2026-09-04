defmodule TodoServer do
  def start do
    pid = spawn(fn -> loop(TodoList.new()) end)
    Process.register(pid, :todo_server)
  end

  def add_entry(new_entry) do
    send(:todo_server, {:add_entry, new_entry})
  end

  def entries(date) do
    send(:todo_server, {:entries, self(), date})

    receive do
      {:todo_entries, entries} -> entries
    after
      5000 -> {:error, :timeout}
    end
  end

  def update_entry(entry_id, updater_fun) do
    send(:todo_server, {:update_entry, entry_id, updater_fun})
  end

  def delete_entry(entry_id) do
    send(:todo_server, {:delete_entry, entry_id})
  end

  defp loop(todo_list) do
    new_todo_list =
      receive do
        message -> process_message(todo_list, message)
      end

    loop(new_todo_list)
  end

  defp process_message(todo_list, {:entries, caller, date}) do
    send(caller, {:todo_entries, TodoList.entries(todo_list, date)})
    todo_list
  end

  defp process_message(todo_list, {:add_entry, entry}) do
    TodoList.add_entry(todo_list, entry)
  end

  defp process_message(todo_list, {:update_entry, entry_id, updater_fun}) do
    TodoList.update_entry(todo_list, entry_id, updater_fun)
  end

  defp process_message(todo_list, {:delete_entry, entry_id}) do
    TodoList.delete_entry(todo_list, entry_id)
  end
end

defmodule TodoList do
  alias MultiDict

  defstruct auto_id: 1, entries: %{}

  def new(entries \\ []) do
    Enum.reduce(
      entries,
      %TodoList{},
      fn entry, todo_list_acc -> add_entry(todo_list_acc, entry) end
    )
  end

  def add_entry(todo_list, entry) do
    # set new entry id
    entry = Map.put(entry, :id, todo_list.auto_id)
    # add new entry to entries list
    new_entries = Map.put(todo_list.entries, todo_list.auto_id, entry)
    # update the struct
    %TodoList{todo_list | entries: new_entries, auto_id: todo_list.auto_id + 1}
  end

  def entries(todo_list, date) do
    todo_list.entries
    |> Stream.filter(fn {_, entry} -> entry.date == date end)
    |> Enum.map(fn {_, entry} -> entry end)
  end

  # def entries(todo_list, date) do
  #   MultiDict.get(todo_list,date)
  # end
  def update_entry(todo_list, entry_id, updater_fun) do
    case Map.fetch(todo_list.entries, entry_id) do
      :error ->
        todo_list

      {:ok, old_entry} ->
        old_entry_id = old_entry.id
        new_entry = %{id: ^old_entry_id} = updater_fun.(old_entry)
        new_entries = Map.put(todo_list.entries, new_entry.id, new_entry)
        %TodoList{todo_list | entries: new_entries}
    end
  end

  def delete_entry(todo_list, entry_id) do
    case Map.fetch(todo_list.entries, entry_id) do
      :error ->
        todo_list

      {:ok, _entries} ->
        delete_entry = Map.delete(todo_list.entries, entry_id)
        %TodoList{todo_list | entries: delete_entry}
    end
  end
end

defmodule TodoList.CsvImporter do
  def import(file_path) do
    file_path
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split(&1, ","))
    |> Stream.map(fn [date, title] ->
      %{
        date: date,
        title: title
      }
    end)
  end
end
