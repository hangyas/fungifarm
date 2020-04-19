defmodule FarmUnit.Uplink do
  @moduledoc ~S"""
  "client" side of the connection

  tries to connect to a satelite, when succeeds sends metadata
  and monitors the connection, if need be reconnects
  """

  @doc ~S"""
  required opts:
    - remote
      node to connect to
    - metadata
  """
  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def start_link(opts) do
    Task.start_link(__MODULE__, :start, [opts])
  end

  def start(opts) do
    :syn.join(:uplinks, self(), opts[:metadata])
    connect(opts)
  end

  # private

  defp connect(opts) do
    remote = opts[:remote]

    try do
      with true <- Node.connect(remote),
           true <- Node.monitor(remote, true) do

        :ok = :rpc.call(remote, Fungifarm.SinkManager, :register_uplink, [opts[:metadata], [from: node()]])
        IO.puts("Connected")
        monitor(opts)
      else
        # node couldn't connect
        _ ->
          Process.sleep(2000)
          connect(opts)
      end
    catch
      :exit, _ ->
        # node connected, but the application isn't running yet
        Process.sleep(2000)
        connect(opts)
    end
  end

  defp monitor(opts) do
    receive do
      {:nodedown, _} ->
        IO.puts("Connection lost. Reconnecting...")
        connect(opts)

      error ->
        IO.puts("Unkown error in Uplink:")
        IO.inspect(error)
        monitor(opts)
    end
  end
end
