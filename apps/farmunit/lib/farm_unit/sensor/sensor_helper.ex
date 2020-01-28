defmodule FarmUnit.Sensor.SensorHelper do
  def aggregate_samples(samples) do
    Enum.reduce(samples, %{}, fn measurement, result ->
      measurement
      |> Map.to_list()
      |> Enum.reduce(result, fn {key, value}, acc ->
        existing_values = Map.get(acc, key, [])
        new_values = existing_values ++ [value]
        Map.put(acc, key, new_values)
      end)
    end)
  end

  def remove_spikes(values) do
    avg = Enum.sum(values) / length(values)
    distance_square = Enum.map(values, fn value -> (avg - value) * (avg - value) end)
    avg_distance_square = Enum.sum(distance_square) / length(distance_square)

    Enum.zip(values, distance_square)
    |> Enum.filter(fn {_value, distance_square} ->
      distance_square == 0 || distance_square / avg_distance_square < 2
    end)
    |> Enum.map(fn {value, _distance_square} -> value end)
  end
end
