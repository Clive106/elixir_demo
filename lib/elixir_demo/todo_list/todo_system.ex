defmodule TodoSystem do
  use Supervisor

  def start_link(), do: Supervisor.start_link(__MODULE__, nil)
  def init(_), do: Supervisor.init([TodoCache, TodoDatabase], strategy: :one_for_one)
end
