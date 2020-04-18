defmodule FarmUnit do

  alias FarmUnit.Procnames

  def emit_measurement(measurement, metadata) do
    :syn.publish(
      Procnames.sensor_subscribers_group(),
      {measurement, metadata}
    )
  end

  # def metadata() do
  #   %{
  #     node: node(),
  #     name: "fake node on raspberry",
  #     sensors: %{
  #       temperature: %{
  #         type: FarmUnit.Sensor.FakeTemperature,
  #         unit: "℃"
  #       },
  #       humidity: %{
  #         type: FarmUnit.Sensor.FakeHumidity,
  #         unit: "%"
  #       }
  #     }
  #   }
  # end
end
