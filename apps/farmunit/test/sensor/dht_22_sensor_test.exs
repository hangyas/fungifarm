defmodule FarmUnit.Sensor.DHT22SensorTest do
  use ExUnit.Case

  alias FarmUnit.Sensor.DHT22Sensor

  test "reads json values" do
    assert DHT22Sensor.read_samples(%{command: ~s(echo {"asd": 1}), sample_size: 3}) == [
             %{"asd" => 1},
             %{"asd" => 1},
             %{"asd" => 1}
           ]
  end

  test "process samples" do
    assert DHT22Sensor.process_samples([
      %{"asd" => 1},
      %{"asd" => 1},
      %{"asd" => 1}
    ]) == [{"asd", 1}]

    assert DHT22Sensor.process_samples([
      %{"asd" => 1},
      %{"asd" => 2},
      %{"asd" => 3}
    ]) == [{"asd", 2}]

    assert DHT22Sensor.process_samples([
      %{"asd" => 2},
      %{"asd" => 1},
      %{"asd" => 2},
      %{"asd" => 1},
      %{"asd" => 115},
      %{"asd" => 2},
      %{"asd" => 1}
    ]) == [{"asd", 1.5}]
  end
end
