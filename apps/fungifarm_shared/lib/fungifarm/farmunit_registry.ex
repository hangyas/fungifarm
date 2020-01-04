defmodule Fungifarm.FarmunitRegistry do
  use GenServer

  alias Fungifarm.{Database, Uplink}

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, [{:name, __MODULE__}])
  end

  def register(server_node, node, metadata) do
    GenServer.cast({__MODULE__, server_node}, {:register, node, metadata})
  end

  def farmunits() do
    GenServer.call(__MODULE__, {:farmunits})
  end

  # Server (callbacks)

  @impl true
  def init(registry) do
    :net_kernel.monitor_nodes(true)
    {:ok, registry}
  end

  @impl true
  def handle_cast({:register, node, metadata}, registry) do
    registry = Map.put(registry, node, metadata)
    {:noreply, registry}
  end

  @impl true
  def handle_info({:nodeup, _node}, registry) do
    {:noreply, registry}
  end

  @impl true
  def handle_info({:nodedown, node}, registry) do
    if Map.has_key?(registry, node) do
      registry = Map.delete(registry, node)
      {:noreply, registry}
    else
      {:noreply, registry}
    end
  end

  @impl true
  def handle_call({:farmunits}, _node, registry) do
    {:reply, registry, registry}
  end
end
