defmodule TodoList.Application do
  use Application

  def start(_type, _args) do
    TodoSystem.start_link()
  end
end
