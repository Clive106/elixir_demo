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

  # def add_entry(todo_list, entry)do
  #   MultiDict.add(todo_list, entry.date, entry)
  # end

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
