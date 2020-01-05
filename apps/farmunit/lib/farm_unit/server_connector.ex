defmodule FarmUnit.ServerConnector do
  alias Fungifarm.FarmunitRegistry

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
    Task.start_link(__MODULE__, :connect, [])
  end

  def connect() do
    node = Application.get_env(:farmunit, :fungifarm_node)
    case Node.connect(node) do
      false ->
        Process.sleep(2000)
        connect()
      true ->
        IO.puts("Connected")
        Node.monitor(node, true)
        FarmunitRegistry.register(node, node(), FarmUnit.metadata())
        monitor()
      a -> IO.inspect(a)
    end

  end

  defp monitor() do
    receive do
      {:nodedown, _} ->
        IO.puts "Connection lost. Reconnecting..."
        connect()
      a ->
        IO.puts "Unkown error in ServerConnector:"
        IO.inspect(a)
        monitor()
    end
  end
end
