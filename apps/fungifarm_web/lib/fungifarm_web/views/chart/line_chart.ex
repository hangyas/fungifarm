defmodule FungifarmWeb.Chart.LineChart do
  @default_scale %{
    bottom: 0,
    top: 100
  }

  def data_to_points([], _width, _height), do: ""

  def data_to_path(data, width, height, scale \\ @default_scale)

  def data_to_path(data, _width, _height, _scale) when length(data) < 2, do: ""

  def data_to_path(data, width, height, scale) do
    # data = Enum.map(data, fn e -> e.value end)
    point_count = length(data)
    step = width / (point_count - 1)

    x_axis = Enum.map(0..point_count, &(&1 * step)) # point on the x-axis to use
    data = Enum.map(data, fn p -> move_data_to_scale(p, height, scale) end)
    data = Enum.zip(x_axis, data)

    [first] = Enum.take(data, 1)
    [last] = Enum.take(data, -1)

    data = data |> Enum.drop(1) |> Enum.drop(-1)

    # the first point is special
    {x0, y0} = first
    r_begin = "M #{x0} #{y0} C #{x0 + step / 2} #{y0}"

    # C works like:
    # <control point to left curve> <point> <control point for right curve>
    r = Enum.map(data, fn {x, y} ->
      " #{x - step / 2} #{y} #{x} #{y} #{x + step / 2} #{y}"
    end) |> Enum.join(",")

    # the last one doesnt have right curve
    {xz, yz} = last
    r_end = " #{xz - step / 2} #{yz} #{xz} #{yz} #{xz} #{yz}"

    # make an angular bottom
    r_bottom = " #{width} #{height} #{width} #{height} #{width} #{height} 0 #{height} 0 #{height} 0 #{height}"

    r_begin <> r <> r_end <> r_bottom
  end

  defp move_data_to_scale(data_point, height, scale) do
    (scale.top - data_point) * (height / (scale.top - scale.bottom))
  end
end
