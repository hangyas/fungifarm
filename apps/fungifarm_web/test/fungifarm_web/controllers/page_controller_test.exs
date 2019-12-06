defmodule FungifarmWeb.PageControllerTest do
  use FungifarmWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Fungifarm Monitor"
  end
end
