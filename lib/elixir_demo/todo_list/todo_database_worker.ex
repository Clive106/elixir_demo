defmodule TodoDatabaseWorker do
  use GenServer

  def start_link({db_folder, worker_id}) do
    GenServer.start_link(__MODULE__, db_folder, name: via_tuple(worker_id))
  end

  # def start_link(db_folder) do
  #   GenServer.start_link(__MODULE__, db_folder)
  # end

  def init(db_folder) do
    IO.puts("starting TodoDatabase Workers...")
    File.mkdir_p!(db_folder)

    {:ok, db_folder}
  end

  # def handle_call({:get, key}, _caller, db_folder) do
  #   data =
  #     case File.read(file_name(db_folder, key)) do
  #       {:ok, content} -> :erlang.binary_to_term(content)
  #       _ -> nil
  #     end

  #   {:reply, data, db_folder}
  # end

  def handle_call({:get, key}, caller, state) do
    spawn(fn ->
      data =
        case File.read(file_name(state, key)) do
          {:ok, content} -> :erlang.binary_to_term(content)
          _ -> nil
        end

      # responds from the spawned process
      GenServer.reply(caller, data)
    end)

    {:noreply, state}
  end

  def handle_cast({:store, key, data}, state) do
    spawn(fn ->
      file_name(state, key)
      |> File.write!(:erlang.term_to_binary(data))
    end)

    {:noreply, state}
  end

  # def handle_cast({:store, key, data}, db_folder) do
  #   spawn(fn ->
  #     file_name(db_folder, key)
  #     |> File.write!(:erlang.term_to_binary(data))
  #   end)

  #   {:noreply, db_folder}
  # end

  defp file_name(db_folder, key) do
    Path.join(db_folder, to_string(key))
  end

  defp via_tuple(worker_id) do
    TodoProcessRegistry.via_tuple({__MODULE__, worker_id})
  end

  # Interface functions
  def store(worker_id, key, data) do
    GenServer.cast(via_tuple(worker_id), {:store, key, data})
  end

  def get(worker_id, key) do
    GenServer.call(via_tuple(worker_id), {:get, key})
  end
end
