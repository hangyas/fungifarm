defmodule FarmUnit.Sensor.FakeSensor do
  alias Fungifarm.Measurement

  @update_interval 1_000

  def child_spec(opts) do
    %{
      id: opts[:id],
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def start_link(args) do
    Task.start_link(__MODULE__, :loop, [args])
  end

  def loop(args) do
    Process.sleep(@update_interval)

    emit_results(args)

    loop(args)
  end

  defp emit_results(args) do
    FarmUnit.emit_measurement(
      %Measurement{
        time: DateTime.utc_now(),
        value: :rand.uniform(100)
      },
      args
    )
  end
end
