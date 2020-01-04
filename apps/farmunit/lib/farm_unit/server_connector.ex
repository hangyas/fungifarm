defmodule FarmUnit.ServerConnector do

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
    Task.start_link(__MODULE__, :loop, [])
  end

  def loop() do
    node = Application.get_env(:farmunit, :fungifarm_node)
    case Node.connect(node) do
      false ->
        Process.sleep(2000)
        loop()
      true ->
        IO.puts("Connected")
        Node.monitor(node, true)
        read()
      a -> IO.inspect(a)
    end

  end

  def read() do
    receive do
      {:nodedown, _} ->
        IO.puts "Connection lost. Reconnecting..."
        loop()
      a ->
        IO.puts "Unkown error in ServerConnector:"
        IO.inspect(a)
    end
  end
end
