defmodule FungifarmWeb.Live.Index do
  use Phoenix.LiveView

  alias Fungifarm.{Sensor, Measurement, Database, Database, Uplink, FarmunitRegistry}

  def mount(_session, socket) do
    with [unit] <- Map.keys(FarmunitRegistry.farmunits()) do
      subscribe_to_sensors(unit)

      clicks = 0

      humidity_report = load_report("humidity", 12 * 60 * 60)
      temperature_report = load_report("temperature", 12 * 60 * 60)
      [unit] = Map.keys(FarmunitRegistry.farmunits())

      {:ok,
      socket
      |> assign(
        unit: unit,
        clicks: clicks,
        recent_humidity: [],
        recent_temperature: [],
        humidity: %{
          unit: unit,
          sensor: :humidity
        },
        temperature: %{
          unit: unit,
          sensor: :temperature
        },
        current_temperature: Database.current("temperature").value,
        current_humidity: Database.current("humidity").value,
        humidity_report: humidity_report,
        temperature_report: temperature_report
      )}
    else
      [] -> {:ok, socket |> assign(unit: nil)}
    end
  end

  # needed for live_link as well
  def handle_params(_params, _uri, socket) do
    if socket.assigns.unit == nil do
      {:noreply, socket  |> live_redirect(to: "/no-nodes")}
    else
      {:noreply, socket}
    end
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

  def handle_event("set_interval", %{"attr" => "humidity", "seconds" => seconds}, socket) do
    {seconds, ""} = Integer.parse(seconds)

    {:noreply, socket |> assign(humidity_report: load_report("humidity", seconds))}
  end

  def handle_event("set_interval", %{"attr" => "temperature", "seconds" => seconds}, socket) do
    {seconds, ""} = Integer.parse(seconds)

    {:noreply, socket |> assign(humidity_report: load_report("temperature", seconds))}
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

  defp subscribe_to_sensors(unit) do
    Uplink.subscribe(unit, :temperature)
    Uplink.subscribe(unit, :humidity)
  end

  defp load_report(attr, seconds) do
    from = (DateTime.utc_now() |> DateTime.add(-seconds))
    until = DateTime.utc_now()

    %{
      values: Database.get_range(attr, from, until) |> Enum.map(fn e -> e.value end),
      min: Database.min(attr, from, until),
      max: Database.max(attr, from, until),
      avg: Database.avg(attr, from, until)
    }
  end
end
