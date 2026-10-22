defmodule TodoDatabase do
  @moduledoc """
  This module is a supervisor that manages a pool of TodoDatabaseWorker processes.
  """

  # @pool_size 3
  # @db_folder "./persist"

  def child_spec(_) do
    pool_size = Application.fetch_env!(:elixir_demo, :pool_size)
    db_folder = Application.fetch_env!(:elixir_demo, :db_folder)
    File.mkdir_p!(db_folder)

    :poolboy.child_spec(
      __MODULE__,
      [
        name: {:local, __MODULE__},
        worker_module: TodoDatabaseWorker,
        size: pool_size
      ],
      [db_folder]
    )
  end

  # def start_link() do
  #   File.mkdir(@db_folder)

  #   children = Enum.map(1..@pool_size, &worker_spec/1)
  #   Supervisor.start_link(children, strategy: :one_for_one)
  # end

  def worker_spec(worker_id) do
    db_folder = Application.fetch_env!(:elixir_demo, :db_folder)
    default_worker_spec = {TodoDatabaseWorker, {db_folder, worker_id}}
    Supervisor.child_spec(default_worker_spec, id: worker_id)
  end

  @doc """
  specifies tododatabase as a supervisor and can be started by invoked TodoDatabase.start_link()
  """

  # def child_spec(_) do
  #   %{
  #     id: __MODULE__,
  #     start: {__MODULE__, :start_link, []},
  #     type: :supervisor
  #   }
  # end

  def get(key) do
    :poolboy.transaction(__MODULE__, fn worker_pid ->
      TodoDatabaseWorker.get(worker_pid, key)
    end)
  end

  def store(key, data) do
    :poolboy.transaction(__MODULE__, fn worker_pid ->
      TodoDatabaseWorker.store(worker_pid, key, data)
    end)
  end

  # defp choose_worker(key) do
  #   :erlang.phash2(key, @pool_size) + 1
  # end
end
