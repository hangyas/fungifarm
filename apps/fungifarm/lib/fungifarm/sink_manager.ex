defmodule Fungifarm.SinkManager do

  @moduledoc ~S"""
  Starts datasink for every measurement queue on the units
  """

  alias Fungifarm.{ DataSink }

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

  # -- frontend --

  @doc ~S"""
  Called from the uplinks with :rpc after join
  """
  def register_uplink(uplink) do
    :syn.send(__MODULE__, {:register, uplink})
  end

  # -- backend --

  def start(opts) do
    :syn.register(__MODULE__, self())

    :syn.get_members(:uplinks, :with_meta)
      |> Enum.each(fn {_pid, data} ->
        start_sink(data)
      end)

    loop(opts)
  end

  def loop(opts) do

    receive do
      {:register, uplink} ->
        start_sink(uplink)
    end

    loop(opts)
  end

  defp start_sink(%{measurements: measurements}) do
    IO.puts "start sink for #{measurements}"
    DataSink.start_link(measurements)
  end
end
