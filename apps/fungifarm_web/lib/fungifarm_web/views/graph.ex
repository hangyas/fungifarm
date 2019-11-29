defmodule FungifarmWeb.Graph do
  use Phoenix.LiveView

  def data_to_points([], width, height), do: ""

  def data_to_points(data, width, height) do
    point_count = length(data)
    step = width / point_count

    x_axis = Enum.map(0..point_count, &(&1 * step))

    x_axis
    |> Enum.zip(data)
    |> Enum.flat_map(fn {x, y} -> [x, y] end)
    |> Enum.join(",")
  end
end
