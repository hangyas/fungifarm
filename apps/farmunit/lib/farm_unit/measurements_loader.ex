defmodule FarmUnit.MeasurementsLoader do
  alias Fungifarm.Measurement
  alias FarmUnit.Procnames

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def start_link(args) do
    Task.start_link(__MODULE__, :init, [args])
  end

  def init(args) do
    :syn.join(Procnames.sensor_subscribers_group(), self())
    loop(args)
  end

  def loop(args) do
    receive do
      msg = {%Measurement{}, _} ->
        PulletMQ.push(
          :syn.whereis(Procnames.measurements_queue()),
          msg
        )
    end

    loop(args)
  end
end
