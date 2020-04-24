defmodule FarmUnit.Sensor.DHT22Sensor do
  alias Fungifarm.Measurement
  import FarmUnit.Sensor.SensorHelper

  def child_spec(opts) do
    %{
      id: opts[:id],
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def start_link(opts) do
    Task.start_link(__MODULE__, :loop, [Map.new(opts)])
  end

  def loop(opts = %{update_interval: update_interval}) do
    read_samples(opts) |> process_samples() |> emit_results()

    Process.sleep(update_interval)
    loop(opts)
  end

  def read_samples(_opts = %{command: command, sample_size: sample_size}) do
    Enum.map(1..sample_size, fn _ -> run_command(command) end)
  end

  defp run_command(command) do
    [command | args] = String.split(command, " ")
    {json, 0} = System.cmd(command, args)
    {:ok, r = %{"temperature" => _, "humidity" => _}} = JSON.decode(json)
    r
  end

  def process_samples(samples) do
    samples
    |> aggregate_samples()
    |> Map.to_list()
    # remove spikes
    |> Enum.map(fn {key, values} -> {key, remove_spikes(values)} end)
    # average
    |> Enum.map(fn {key, values} -> {key, Enum.sum(values) / length(values)} end)
  end

  defp emit_results(%{"temperature" => temperature, "humidity" => humidity}) do
    FarmUnit.emit_measurement(
      %Measurement{
        time: DateTime.utc_now(),
        value: temperature
      },
      id: Sensors.DHT22.Temperature,
      name: "temperature"
    )

    FarmUnit.emit_measurement(
      %Measurement{
        time: DateTime.utc_now(),
        value: humidity
      },
      id: Sensors.DHT22.Humidity,
      name: "humidity"
    )
  end
end
