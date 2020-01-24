defmodule FungifarmWeb.Live.SensorHistory do
  use Phoenix.LiveView

  alias Fungifarm.{Sensor, Measurement, Database, Database, Uplink, FarmunitRegistry}

  def mount(_session, socket) do
    {:ok, socket}
  end

  def handle_params(_params = %{"name" => sensor_name}, _uri, socket) do
    attr_name = sensor_name |> URI.decode()
    report = load_report(attr_name, 24 * 60 * 60)

    socket = socket |> assign(
      attr_name: attr_name,
      report: report
    )

    {:noreply, socket}
  end

  def render(assigns) do
    FungifarmWeb.PageView.render("sensor_history.html", assigns)
  end

  # private functions

  defp load_report(attr, seconds) do
    from = (DateTime.utc_now() |> DateTime.add(-seconds))
    until = DateTime.utc_now()

    values = Database.get_range(attr, from, until) |> Enum.map(fn e -> e.value end)
    %{
      values: values,
      last: List.last(values),
      min: Database.min(attr, from, until),
      max: Database.max(attr, from, until),
      avg: Database.avg(attr, from, until)
    }
  end
end
