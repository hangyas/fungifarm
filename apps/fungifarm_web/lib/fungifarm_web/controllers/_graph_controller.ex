defmodule FungifarmWeb.GraphController do
  use FungifarmWeb, :controller
  alias Phoenix.LiveView


  def show(conn, _params) do
    LiveView.Controller.live_render(conn, FungifarmWeb.Live.Graph, session: %{})
  end
end
