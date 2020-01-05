defmodule FungifarmWeb.PageController do
  use FungifarmWeb, :controller
  alias Phoenix.LiveView


  def index(conn, _params) do
    LiveView.Controller.live_render(conn, FungifarmWeb.Live.Index, session: %{})
  end
end
