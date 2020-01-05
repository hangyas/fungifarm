defmodule Fungifarm.DataSink do
  alias Fungifarm.{Database, Uplink}

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def start_link(_args) do
    {:ok, pid} = Task.start_link(__MODULE__, :main, [])
    Process.register(pid, __MODULE__)
    {:ok, pid}
  end

  def main() do
    loop()
  end

  def register(node) do
    send(__MODULE__, {:register, node})
  end

  defp loop() do
    receive do
      {:register, node} -> subscribe_to_sensors(node)
      {:sensor_update, sensor, measurement} -> handle_sensor_update(sensor, measurement)
    end
    loop()
  end

  defp subscribe_to_sensors(unit) do
    # TODO subscribe based on metadata
    Uplink.subscribe(unit, :temperature)
    Uplink.subscribe(unit, :humidity)
  end

  defp handle_sensor_update(sensor, measurement) do
    Database.save(sensor, measurement)
  end

end
