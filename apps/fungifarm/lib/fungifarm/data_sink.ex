defmodule Fungifarm.DataSink do
  alias Fungifarm.{Database, Uplink}

  # Database.save(sensor, measurement)

  def start_link(pullet_proc_name) do
    Task.start_link(__MODULE__, :main, [pullet_proc_name])
  end

  def main(pullet_proc_name) do
    # waits for syn
    pullet = get_pid(pullet_proc_name)

    Process.monitor(pullet)

    loop(pullet)
  end

  defp loop(pullet) do
    PulletMQ.request(pullet)

    receive do
      {:item, item} ->
        IO.inspect(item)
        loop(pullet)

      {:DOWN, _, :process, _, :noconnection} ->
        IO.puts("datasink stopped")

      error ->
        IO.inspect(error)
    end
  end

  defp get_pid(name) do
    pid = :syn.whereis(name)

    if pid == :undefined do
      Process.sleep(500) # TODO this probably isnt the best solution
      get_pid(name)
    else
      pid
    end
  end
end
