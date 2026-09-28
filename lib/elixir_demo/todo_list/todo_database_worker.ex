defmodule TodoDatabaseWorker do
  use GenServer

  def start(db_folder) do
    GenServer.start(__MODULE__, db_folder)
  end

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

  def store(worker, key, data) do
    GenServer.cast(worker, {:store, key, data})
  end

  def get(worker, key) do
    GenServer.call(worker, {:get, key})
  end
end
