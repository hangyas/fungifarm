defmodule Fungifarm.DataSink do
  alias Fungifarm.{Database, Measurement}

  def start_link(pullet_mq) do
    Task.start_link(__MODULE__, :main, [pullet_mq])
  end

  def main(pullet_mq) do
    Process.monitor(pullet_mq)

    loop(pullet_mq)
  end

  defp loop(pullet) do
    try do
      PulletMQ.request(pullet)
    catch
      :exit, {{:nodedown, _}, _} ->
        IO.puts("pullet's node is down")
    end

    receive do
      {:item, {measurement = %Measurement{}, metadata}} ->
        Database.save(metadata[:id], measurement)
        loop(pullet)

      {:DOWN, _, :process, _, :noconnection} ->
        IO.puts("datasink stopped")
    end
  end
end
