defmodule Uplink.Satelite do
  @doc ~S"""
  "server" side of the connection

  ## state
   - lilst of connected uplinks (with metadata)
  """

  use GenServer

  @initial_state %{
    uplinks: []
  }

  def start_link(_), do: start_link()

  def start_link() do
    GenServer.start_link(__MODULE__, @initial_state, name: __MODULE__)
  end

  # -- frontend --

  def add_uplink(satelite_node, uplink_node, metadata) do
    GenServer.call({__MODULE__, satelite_node}, {:add_uplink, uplink_node, metadata})
  end

  def get_uplinks(satelite_node \\ node()) do
    GenServer.call({__MODULE__, satelite_node}, {:get_uplinks})
  end

  # -- backend --

  def init(state) do
    {:ok, state}
  end

  def handle_call(
        {:add_uplink, uplink_node, metadata},
        _from,
        state = %{uplinks: uplinks}
      ) do
    IO.puts("uplink up #{inspect(uplink_node)}")

    Node.monitor(uplink_node, true)
    Fungifarm.DataSink.start_link(metadata.measurements)

    uplinks = uplinks ++ [{uplink_node, metadata}]

    {:reply, :ok, state |> Map.put(:uplinks, uplinks)}
  end

  def handle_call({:get_uplinks}, _from, state = %{uplinks: uplinks}) do
    {:reply, uplinks, state}
  end

  def handle_info({:nodedown, node}, state = %{uplinks: uplinks}) do
    IO.puts("uplink down #{inspect(node)}")

    uplinks =
      uplinks
      |> Enum.filter(fn {uplink_node, _metadata} ->
        node != uplink_node
      end)

    {:noreply, state |> Map.put(:uplinks, uplinks)}
  end

  # -- private --
end
