defmodule Fungifarm.DataSink do
  alias Fungifarm.{Database, Measurement}

  @config Application.get_env(:farmunit, :data_sink)

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
        process_item(metadata, measurement)
        loop(pullet)

      {:DOWN, _, :process, _, :noconnection} ->
        IO.puts("datasink stopped")
    end
  end

  defp process_item(metadata, measurement) do
    if @config[:db] do
      Database.save(metadata[:id], measurement)
    end

    if @config[:log] do
      IO.inspect({metadata, measurement})
    end
  end
end
