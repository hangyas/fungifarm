defmodule FarmUnit.Sensor.SensorHelperTest do
  use ExUnit.Case

  alias FarmUnit.Sensor.SensorHelper

  test "removes spikes corrrectly" do
    assert SensorHelper.remove_spikes([1, 2, 3, 343]) == [1, 2, 3]
    assert SensorHelper.remove_spikes([1, 2, 3, -6]) == [1, 2, 3]
    assert SensorHelper.remove_spikes([1, 2, 3]) == [1, 2, 3]
    # assert SensorHelper.remove_spikes([1, 115, 2]) == [1, 2]
    assert SensorHelper.remove_spikes([3, 2, 3]) == [3, 2, 3]
    IO.inspect SensorHelper.remove_spikes([44, 50, 50]) == [50, 50]
    assert SensorHelper.remove_spikes([44, 50, 50]) == [50, 50]
    assert SensorHelper.remove_spikes([46, 49, 49]) == [49, 49]
    assert SensorHelper.remove_spikes([49, 46, 49]) == [49, 49]
    assert SensorHelper.remove_spikes([1, 1, 1, 1, 100]) == [1, 1, 1, 1]
  end

  test "aggregate_samples" do
    assert SensorHelper.aggregate_samples([%{"a" => 1}, %{"a" => 2}]) == %{"a" => [1, 2]}

    assert SensorHelper.aggregate_samples([%{"a" => 1, "b" => 2}, %{"a" => 2, "b" => 1}]) == %{
             "a" => [1, 2],
             "b" => [2, 1]
           }
  end
end
