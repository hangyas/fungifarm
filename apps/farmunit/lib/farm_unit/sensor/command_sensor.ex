defmodule FarmUnit.Sensor.CommandSensor do
  alias FarmUnit.Sensor.Impl
  alias Fungifarm.{Sensor, Measurement}

  @behaviour Impl

  @update_interval 5_000

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
    Task.start_link(__MODULE__, :loop, [args[:command]])
  end

  def loop(command) do
    receive do
      # not doing anything with messages
    after
      # receive timeout
      @update_interval ->
        data = run_command(command)
        emit_results("temperature", data["temperature"])
        emit_results("humidity", data["humidity"])
        loop(command)
    end
  end

  defp run_command(command) do
    {json, 0} = System.cmd(command, [])
    {:ok, r} = JSON.decode(json)
    r
  end

  defp emit_results(name, data) do
    data = {
      :sensor_update,
      %Sensor{
        node: "fake-node",
        chip: __MODULE__,
        attribute: name
      },
      %Measurement{
        time: DateTime.utc_now(),
        value: data
      }
    }

    PubSub.publish(String.to_atom(name), data)
    # TODO send more metadata (unit_id, sensor name..)
  end

  def attributes(), do: [:i_have_to_rethink_this]
end
