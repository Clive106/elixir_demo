defmodule MultiDict do

   # def new(), do: %TodoList{}

  # def add_entry(todo_list, date, title)do
  # Map.update(todo_list, date, [title], fn titles-> [title | titles] end)
  # end

  # def entries(todo_list, date)do
  #  Map.get(todo_list, date, [])
  # end

  def new(), do: %{}

  def add(dict, key, value) do
    Map.update(dict, key, [value], &[value | &1])
  end

  def get(dict, key) do
    Map.get(dict, key, [])
  end
end
