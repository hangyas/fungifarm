defmodule FungifarmWeb.Live.Index do
  use Phoenix.LiveView

  alias Fungifarm.Database

  def mount(_session, socket) do
    alerts = Database.get_something()
    clicks = 0
    data = Poison.encode!([[175, 60], [190, 80], [180, 75]])
    {:ok, assign(socket, clicks: clicks, data: data, alerts: alerts)}
  end

  def render(assigns) do
    FungifarmWeb.PageView.render("index.html", assigns)
  end

  def handle_event("increase_click", %{"amount" => amount} = _values, socket) do
    {amount, ""} = Integer.parse(amount)
    IO.inspect(amount)
    clicks = socket.assigns.clicks + amount
    IO.inspect(clicks)
    {:noreply, assign(socket, clicks: clicks)}
  end
end
