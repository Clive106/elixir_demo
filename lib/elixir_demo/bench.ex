
defmodule Bench do
  def run(module, _opts \\ []) do
    # Start the GenServer if it isn't already running.
    unless Process.whereis(module) do
      {:ok, _pid} = module.start_link()
    end

    iterations = 1_000_000

    IO.puts("Benchmarking #{inspect(module)}...")

    {time_microseconds, _result} =
      :timer.tc(fn ->
        Enum.each(1..iterations, fn i ->
          module.put(i, i)
          module.get(i)
        end)
      end)

    total_operations = iterations * 2

    operations_per_second =
      round(total_operations / (time_microseconds / 1_000_000))

    IO.puts("#{operations_per_second} operations/sec")
  end
end
