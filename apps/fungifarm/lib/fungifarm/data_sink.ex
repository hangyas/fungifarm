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
    Task.start_link(__MODULE__, :main, [])
  end

  def main() do
    loop()
  end

  def subscribe_to_sensors(unit) do
    Uplink.subscribe(unit, :temperature)
    Uplink.subscribe(unit, :humidity)
  end

  defp loop() do
    receive do
      {:sensor_update, sensor, measurement} -> handle_sensor_update(sensor, measurement)
    end
    loop()
  end

  defp handle_sensor_update(sensor, measurement) do
    Database.save(sensor, measurement)
  end

end
