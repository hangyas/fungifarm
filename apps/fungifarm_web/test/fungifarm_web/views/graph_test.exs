defmodule FungifarmWeb.GraphTest do
  use FungifarmWeb.ConnCase, async: true
  alias FungifarmWeb.Graph

  test "draws small example" do
    assert "M 0.0 34 C 25.0 34 25.0 23 50.0 23 75.0 23 75.0 43 100.0 43 100.0 43 100 100 100 100 100 100 0 100 0 100 0 100" =
             Graph.data_to_path([34, 23, 43], 100, 100)
  end
end