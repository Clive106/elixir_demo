defmodule TodoDatabase do
  use GenServer

  @db_folder "./persist"

  def start() do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  @doc """
  confirms the data folder exists
  """
  def init(_) do
    File.mkdir_p!(@db_folder)
    {:ok, nil}
  end

  @doc """
  reads data from file system
  """
  def handle_call({:get, key}, caller, state) do
    spawn(fn ->
      data =
        case File.read(file_name(key)) do
          {:ok, content} -> :erlang.binary_to_term(content)
          _ -> nil
        end

      # responds from the spawned process
      GenServer.reply(caller, data)
    end)

    {:noreply, state}
  end

  @doc """
  stores data in the file system
  """
  def handle_cast({:store, key, data}, state) do
    spawn(fn ->
      file_name(key)
      |> File.write!(:erlang.term_to_binary(data))
    end)

    {:noreply, state}
  end

  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  def store(key, data) do
    GenServer.cast(__MODULE__, {:store, key, data})
  end

  defp file_name(key) do
    Path.join(@db_folder, to_string(key))
  end
end
