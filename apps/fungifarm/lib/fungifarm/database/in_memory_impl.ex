defmodule Fungifarm.Database.InMemoryImpl do
  use GenServer

  alias Fungifarm.Database.Impl
  @behaviour Impl

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl Impl
  def get_something(), do: {:ok, ["some data"]}

  @impl Impl
  def current(attr) do
    GenServer.call(__MODULE__, {:current, attr})
  end

  @impl Impl
  def save(sensor, measurement) do
    GenServer.call(__MODULE__, {:save, sensor, measurement})
  end

  # Server

  @impl GenServer
  def init(init_arg) do
    {:ok, init_arg}
  end

  @impl GenServer
  def handle_call({:current, attr}, _from, db) do
    current = db |> Map.get(attr) |> List.last()
    {:reply, current, db}
  end

  @impl GenServer
  def handle_call({:save, sensor, measurement}, _from, db) do
    vals = Map.get(db, sensor.attribute, [])
    vals = vals ++ [measurement.value]
    db = Map.put(db, sensor.attribute, vals)
    {:reply, :ok, db}
  end

end
