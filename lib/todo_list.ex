defmodule ElixirDemo.TodoList do
  alias TodoList.MultiDict
  def new, do: %{}



  def add_entry(todo_list, date, title)do
    MultiDict.add(todo_list, date, title)
  end

  def entries(todo_list, date) do
    MultiDict.entries(todo_list,date)
  end
end
