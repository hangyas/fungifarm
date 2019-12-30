defmodule FungifarmWeb.Live.Index do
  use Phoenix.LiveView

  alias Fungifarm.{Sensor, Measurement}
  alias Fungifarm.Database
  alias Fungifarm.Uplink

  def mount(_session, socket) do
    subscribe_to_sensors()

    {:ok, alerts} = Database.get_something()
    clicks = 0

    report = load_report(600)

    {:ok,
     socket
     |> assign(
       clicks: clicks,
       alerts: alerts,
       recent_temperature: [],
       recent_humidity: [],
       current_temperature: Database.current("temperature").value,
       current_humidity: Database.current("humidity").value,
       history_humidity: report
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

  def handle_event("set_interval", %{"seconds" => seconds}, socket) do
    {seconds, ""} = Integer.parse(seconds)

    {:noreply, socket |> assign(history_humidity: load_report(seconds))}
  end

  # events from the farmunit

  def handle_info({:sensor_update, %Sensor{attribute: "temperature"}, %Measurement{value: value}}, socket) do
    recent_temperature = Enum.take(socket.assigns.recent_temperature ++ [value], -10)
    {:noreply, socket |> assign(recent_temperature: recent_temperature, current_temperature: value)}
  end

  def handle_info({:sensor_update, %Sensor{attribute: "humidity"}, %Measurement{value: value}}, socket) do
    recent_humidity = Enum.take(socket.assigns.recent_humidity ++ [value], -10)
    {:noreply, socket |> assign(recent_humidity: recent_humidity, current_humidity: value)}
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
