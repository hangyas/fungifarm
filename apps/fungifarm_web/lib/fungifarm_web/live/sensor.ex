defmodule FungifarmWeb.Live.Sensor do
  use Phoenix.LiveView

  alias Fungifarm.{Sensor, Measurement, Database, Database, Uplink, FarmunitRegistry}

  def mount(_session, socket) do
    {:ok, socket}
  end

  def handle_params(_params = %{"node" => node, "name" => sensor_name}, _uri, socket) do
    node = node |> URI.decode() |> String.to_atom()
    sensor_name = sensor_name |> URI.decode() |> String.to_atom()

    subscribe_to_sensor(node, sensor_name)

    metadata = FarmunitRegistry.farmunits()[node].sensors[sensor_name]
    metadata = metadata |> Map.put(:node, node)

    socket = socket |> assign(
      metadata: metadata,
      sensor_name: sensor_name,
      current_value: 0,
      data: []
    )

    {:noreply, socket}
  end

  def render(assigns) do
    FungifarmWeb.PageView.render("sensor.html", assigns)
  end


  # events from the ui

  # events from the farmunit

  def handle_info({:sensor_update, _sensor = %Sensor{}, %Measurement{value: value}}, socket) do
    data = Enum.take(socket.assigns.data ++ [value], -10)
    {:noreply, socket |> assign(data: data, current_value: value)}
  end

  def handle_info(_, socket) do
    {:noreply, socket}
  end

  # private functions

  defp subscribe_to_sensor(unit, sensor_name) do
    Uplink.subscribe(unit, sensor_name)
  end

  defp load_report(seconds) do
    from = (DateTime.utc_now() |> DateTime.add(-seconds))
    until = DateTime.utc_now()

    %{
      values: Database.get_range("humidity", from, until) |> Enum.map(fn e -> e.value end),
      min: Database.min("humidity", from, until),
      max: Database.max("humidity", from, until),
      avg: Database.avg("humidity", from, until)
    }
  end
end
