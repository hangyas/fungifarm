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

    try do
      with true <- Node.connect(node),
           true <- Node.monitor(node, true),
           :ok <- FarmunitRegistry.register(node, node(), FarmUnit.metadata()) do
        IO.puts("Connected")
        monitor()
      else
        # node couldn't connect
        _ ->
          Process.sleep(2000)
          connect()
      end
    catch
      :exit, _ ->
        # node connected, but the application isn't running yet
        Process.sleep(2000)
        connect()
    end
  end

  defp monitor() do
    receive do
      {:nodedown, _} ->
        IO.puts("Connection lost. Reconnecting...")
        connect()

      a ->
        IO.puts("Unkown error in ServerConnector:")
        IO.inspect(a)
        monitor()
    end
  end
end
