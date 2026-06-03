defmodule ElixirDemo.TodoList do
  alias TodoList.MultiDict
  def new, do: %{}



  def add_entry(todo_list, entry)do
    MultiDict.add(todo_list, entry.date, entry)
  end

  def entries(todo_list, date) do
    MultiDict.entries(todo_list,date)
  end
end
