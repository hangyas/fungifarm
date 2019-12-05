defmodule FungifarmWeb.Graph do
  use Phoenix.LiveView

# warning: function render/1 required by behaviour Phoenix.LiveView is not implemented (in module FungifarmWeb.Graph)
#   lib/fungifarm_web/views/graph.ex:1: FungifarmWeb.Graph (module)
# defmodule Asd do
#   def read() do
#     receive do
#       a -> IO.inspect(a)
#     end
#   end
# end


  def data_to_points([], _width, _height), do: ""

  def data_to_points(data, width, _height) do
    point_count = length(data)
    step = width / point_count

    x_axis = Enum.map(0..point_count, &(&1 * step))

    x_axis
    |> Enum.zip(data)
    |> Enum.flat_map(fn {x, y} -> [x, y] end)
    |> Enum.join(",")
  end
end
