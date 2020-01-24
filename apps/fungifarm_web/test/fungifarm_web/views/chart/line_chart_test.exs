defmodule FungifarmWeb.Chart.LineChartTest do
  use FungifarmWeb.ConnCase, async: true
  alias FungifarmWeb.Chart.LineChart

  test "draws small example" do
    assert "M 0.0 66.0 C 25.0 66.0 25.0 77.0 50.0 77.0 75.0 77.0 75.0 57.0 100.0 57.0 100.0 57.0 100 100 100 100 100 100 0 100 0 100 0 100" =
      LineChart.data_to_path([34, 23, 43], 100, 100)
  end

  test "draws small example with custom scale" do
    assert "M 0.0 66.4 C 25.0 66.4 25.0 70.8 50.0 70.8 75.0 70.8 75.0 62.800000000000004 100.0 62.800000000000004 100.0 62.800000000000004 100 100 100 100 100 100 0 100 0 100 0 100" =
      LineChart.data_to_path([34, 23, 43], 100, 100, %{bottom: -50, top: 200})
  end
end
