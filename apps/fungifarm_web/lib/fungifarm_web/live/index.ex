defmodule FungifarmWeb.Live.Index do
  use Phoenix.LiveView

  alias Fungifarm.{Sensor, Measurement}
  alias Fungifarm.Database
  alias Fungifarm.Uplink

  def mount(_session, socket) do
    subscribe_to_sensors()

    {:ok, alerts} = Database.get_something()
    clicks = 0

    {:ok,
     socket
     |> assign(
       clicks: clicks,
       alerts: alerts,
       history_temperature: [],
       history_humidity: [],
       current_temperature: Database.current(:temperature),
       current_humidity: Database.current(:humidity)
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

  def handle_info({:sensor_update, %Sensor{attribute: "temperature"}, %Measurement{value: value}}, socket) do
    history_temperature = Enum.take(socket.assigns.history_temperature ++ [value], -10)
    {:noreply, socket |> assign(history_temperature: history_temperature, current_temperature: value)}
  end

  def handle_info({:sensor_update, %Sensor{attribute: "humidity"}, %Measurement{value: value}}, socket) do
    history_humidity = Enum.take(socket.assigns.history_humidity ++ [value], -10)
    {:noreply, socket |> assign(history_humidity: history_humidity, current_humidity: value)}
  end

  def handle_info(_, socket) do
    {:noreply, socket}
  end

  # private functions

  defp subscribe_to_sensors() do
    [unit] = Uplink.farmunits()
    Uplink.subscribe(unit, :temperature)
    Uplink.subscribe(unit, :humidity)
  end
end
