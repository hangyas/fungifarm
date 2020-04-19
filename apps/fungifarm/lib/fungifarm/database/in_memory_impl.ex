defmodule Fungifarm.Database.InMemoryImpl do
  use GenServer

  alias Fungifarm.Database.Impl
  @behaviour Impl

  def start_link(), do: start_link(nil)

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
  def get_range(attr, from, until) do
    GenServer.call(__MODULE__, {:get_range, attr, from, until})
  end

  @impl Impl
  def min(attr, from, until) do
    GenServer.call(__MODULE__, {:min, attr, from, until})
  end

  @impl Impl
  def max(attr, from, until) do
    GenServer.call(__MODULE__, {:max, attr, from, until})
  end

  @impl Impl
  def avg(attr, from, until) do
    GenServer.call(__MODULE__, {:avg, attr, from, until})
  end

  @impl Impl
  def save(collection, measurement) do
    GenServer.call(__MODULE__, {:save, collection, measurement})
  end

  # Server

  @impl GenServer
  def init(init_arg) do
    {:ok, init_arg}
  end

  @impl GenServer
  def handle_call({:save, collection, measurement}, _from, db) do
    vals = Map.get(db, collection, [])
    vals = vals ++ [measurement]
    db = Map.put(db, collection, vals)
    {:reply, :ok, db}
  end

  @impl GenServer
  def handle_call({:current, attr}, _from, db) do
    current = db |> Map.get(attr) |> List.last()
    {:reply, current, db}
  end

  @impl GenServer
  def handle_call({:get_range, attr, from, until}, _from, db) do
    list = db
    |> Map.get(attr)
    |> Enum.filter(fn e ->
      DateTime.compare(e.time, from) != :lt && DateTime.compare(e.time, until) != :gt
    end)

    {:reply, list, db}
  end

  @impl GenServer
  def handle_call({:min, attr, from, until}, _from, db) do
    min = db
    |> Map.get(attr)
    |> Enum.filter(fn e ->
      DateTime.compare(e.time, from) != :lt && DateTime.compare(e.time, until) != :gt
    end)
    |> Enum.min_by(fn e -> e.value end)

    {:reply, min, db}
  end

  @impl GenServer
  def handle_call({:max, attr, from, until}, _from, db) do
    max = db
    |> Map.get(attr)
    |> Enum.filter(fn e ->
      DateTime.compare(e.time, from) != :lt && DateTime.compare(e.time, until) != :gt
    end)
    |> Enum.max_by(fn e -> e.value end)

    {:reply, max, db}
  end

  @impl GenServer
  def handle_call({:avg, attr, from, until}, _from, db) do
    list = db
    |> Map.get(attr)
    |> Enum.filter(fn e ->
      DateTime.compare(e.time, from) != :lt && DateTime.compare(e.time, until) != :gt
    end)
    |> Enum.map(fn e -> e.value end)

    avg = Enum.sum(list) / length(list)

    {:reply, avg, db}
  end

end
