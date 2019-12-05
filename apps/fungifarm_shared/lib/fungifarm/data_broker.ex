defmodule Fungifarm.DataBroker do
  # start this on the server node

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
    Task.start_link(fn ->
      register_global_process()
      loop()
    end)
  end

  # client interface

  def emit(topic, data) do
    :global.send(Fungifarm.SensorDataBroker.Emitter, {topic, data})
  end

  # wrapping PubSub

  def register_global_process() do
    :global.register_name(Fungifarm.SensorDataBroker.Emitter, self())
  end

  def loop() do
    receive do
      {topic, message} -> PubSub.publish(topic, message)
      a -> IO.inspect a
    end
    loop()
  end
end
