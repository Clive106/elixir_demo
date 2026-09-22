defmodule TodoSystem do
  def start_link(), do:
  Supervisor.start_link( [TodoCache], strategy: :one_for_one)
end
