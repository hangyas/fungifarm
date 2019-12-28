defmodule FarmUnit.Sensor.FakeSensor do
  alias FarmUnit.Sensor.Impl
  alias Fungifarm.{Sensor, Measurement}

  @behaviour Impl

  @update_interval 1_000

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
    Task.start_link(__MODULE__, :loop, [args[:name]])
  end

  def loop(name) do
    receive do
      # not doing anything with messages
    after
      # receive timeout
      @update_interval ->
        emit_results(name)
        loop(name)
    end
  end

  defp emit_results(name) do
    data = {
      :sensor_update,
      %Sensor{
        node: "fake-node",
        chip: __MODULE__,
        attribute: name
      },
      %Measurement{
        time: "just around nowish",
        value: :rand.uniform(100)
      }
    }

    PubSub.publish(String.to_atom(name), data)
    # TODO send more metadata (unit_id, sensor name..)
  end

  def attributes(), do: [:i_have_to_rethink_this]
end
