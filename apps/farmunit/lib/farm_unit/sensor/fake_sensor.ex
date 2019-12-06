defmodule FarmUnit.Sensor.FakeSensor do
  alias FarmUnit.Sensor.Impl

  @behaviour Impl

  @topic :fake_sensor_data
  @update_interval 1_000

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def start_link(_arg) do
    Task.start_link(&loop/0)
  end

  def loop() do
    receive do
      # not doing anything with messages
    after
      # receive timeout
      @update_interval ->
        emit_results()
        loop()
    end
  end

  defp emit_results() do
    data = {
      :sensor_update,
      %{
        name: "vmi",
        value: :rand.uniform(100)
      }
    }

    PubSub.publish(@topic, data)
    # TODO send more metadata (unit_id, sensor name..)
  end

  def attributes(), do: [@topic]
end
