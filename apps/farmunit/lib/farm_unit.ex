defmodule FarmUnit do
  def metadata() do
    %{
      node: node(),
      name: "fake node on raspberry",
      sensors: %{
        temperature: %{
          type: FarmUnit.Sensor.FakeTemperature,
          unit: "℃"
        },
        humidity: %{
          type: FarmUnit.Sensor.FakeHumidity,
          unit: "%"
        }
      }
    }
  end
end
