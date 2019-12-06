defmodule FungifarmWeb.Live.Index do
  use Phoenix.LiveView

  alias Fungifarm.Database
  alias Fungifarm.Uplink

  def mount(_session, socket) do
    subscribe_to_sensors()

    {:ok, alerts} = Database.get_something()
    sensordata = []
    clicks = 0

    {:ok,
     socket
     |> assign(
       clicks: clicks,
       alerts: alerts,
       sensordata: sensordata
     )}
  end

  def render(assigns) do
    FungifarmWeb.PageView.render("index.html", assigns)
  end

  # events from the ui

  def handle_event("increase_click", %{"amount" => amount} = _values, socket) do
    {amount, ""} = Integer.parse(amount)

    clicks = socket.assigns.clicks + amount
    {:noreply, socket |> assign(clicks: clicks)}
  end

  # events from the farmunit

  def handle_info({:sensor_update, %{value: value}}, socket) do
    sensordata = Enum.take(socket.assigns.sensordata ++ [value], -10)
    {:noreply, socket |> assign(sensordata: sensordata)}
  end

  def handle_info(_, socket) do
    {:noreply, socket}
  end

  # private functions

  defp subscribe_to_sensors() do
    [unit] = Uplink.farmunits()
    Uplink.subscribe(unit, :fake_sensor_data)
  end
end
