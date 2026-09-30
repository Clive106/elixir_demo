defmodule TodoDatabase do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @doc """
  creates three workers
  """
  def init(_) do
    IO.puts("starting todo database server....")
    {:ok, _worker0} = TodoDatabaseWorker.start_link({"./persist0", 0})
    {:ok, _worker1} = TodoDatabaseWorker.start_link({"./persist1", 1})
    {:ok, _worker2} = TodoDatabaseWorker.start_link({"./persist2", 2})

    workers = %{
      0 => 0,
      1 => 1,
      2 => 2
    }

    {:ok, workers}
  end

  def handle_call({:get, key}, _caller, workers) do
    worker = choose_worker(workers, key)

    data = TodoDatabaseWorker.get(worker, key)

    {:reply, data, workers}
  end

  def handle_cast({:store, key, data}, workers) do
    worker = choose_worker(workers, key)

    TodoDatabaseWorker.store(worker, key, data)

    {:noreply, workers}
  end

  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  def store(key, data) do
    GenServer.cast(__MODULE__, {:store, key, data})
  end

  defp choose_worker(workers, key) do
    worker_index = :erlang.phash2(key, 3)

    workers[worker_index]
  end
end
