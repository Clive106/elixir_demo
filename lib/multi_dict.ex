defmodule TodoList.MultiDict do

  def new(), do: %{}

  def add(dict, key, value)do
    Map.update(dict, key, [value], &[value | &1 ])
  end
  def entries(dict, key)do
    Map.get(dict, key, [])
  end
end
