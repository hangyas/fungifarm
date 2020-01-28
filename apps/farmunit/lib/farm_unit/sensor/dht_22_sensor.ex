defmodule FarmUnit.Sensor.DHT22Sensor do
  alias FarmUnit.Sensor.Impl
  alias Fungifarm.{Sensor, Measurement}
  import FarmUnit.Sensor.SensorHelper

  @behaviour Impl

  def child_spec(opts) do
    [{:id, id} | _] = opts

    %{
      id: id,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def start_link(args) do
    Task.start_link(__MODULE__, :loop, [args[:settings]])
  end

  def loop(settings = %{update_interval: update_interval}) do
    reading = read_attributes(settings)
    emit_attribute_values(reading)

    Process.sleep(update_interval)
    loop(settings)
  end

  defp read_attributes(settings) do
    process_samples(read_samples(settings))
  end

  def read_samples(_settings = %{command: command, sample_size: sample_size}) do
    Enum.map(1..sample_size, fn _ -> run_command(command) end)
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

  defp run_command(command) do
    [command | args] = String.split(command, " ")
    {json, 0} = System.cmd(command, args)
    {:ok, r} = JSON.decode(json)
    r
  end

  defp emit_attribute_values(data) do
    Enum.each(data, fn {name, value} ->
      emit_attribute_value(name, value)
    end)
  end

  defp emit_attribute_value(name, value) do
    message = {
      :sensor_update,
      %Sensor{
        node: "fake-node",
        chip: __MODULE__,
        attribute: name
      },
      %Measurement{
        time: DateTime.utc_now(),
        value: value
      }
    }

    # TODO send more metadata (unit_id, sensor name..)

    PubSub.publish(String.to_atom(name), message)
  end

  def attributes(), do: [:i_have_to_rethink_this]
end
