defmodule FungifarmWeb.Live.NoNodes do
  use Phoenix.LiveView

  alias Fungifarm.{Sensor, Measurement, Database, Database, Uplink, FarmunitRegistry}

  def mount(_session, socket) do
    # TODO automatically redirect to a unit when its connected
    {:ok, socket}
  end

  # needed for live_link
  # but we dont have url params
  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  def render(assigns) do
    FungifarmWeb.PageView.render("no_nodes.html", assigns)
  end
end
