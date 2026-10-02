defmodule TodoDatabase do
  @moduledoc """
  This module is a supervisor that manages a pool of TodoDatabaseWorker processes.
  """
  @pool_size 3
  @db_folder "./persist"

  def start_link() do
    File.mkdir(@db_folder)

    children = Enum.map(1..@pool_size, &worker_spec/1)
    Supervisor.start_link(children, strategy: :one_for_one)
  end

  def worker_spec(worker_id) do
    default_worker_spec = {TodoDatabaseWorker, {@db_folder, worker_id}}
    Supervisor.child_spec(default_worker_spec, id: worker_id)
  end

  @doc """
  specifies tododatabase as a supervisor and can be started by invoked TodoDatabase.start_link()
  """
  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end

  def get(key) do
    key
    |> choose_worker()
    |> TodoDatabaseWorker.get(key)
  end

  def store(key, data) do
    key
    |> choose_worker()
    |> TodoDatabaseWorker.store(key, data)
  end

  defp choose_worker(key) do
    :erlang.phash2(key, @pool_size) + 1
  end
end
