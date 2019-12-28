defmodule Fungifarm.Measurement do
  # fields can change in every measurement
  # (e.g. shouldn't contein name of the sensor)
  # for that we have Fungirfarm.Sensor

  defstruct [:time, :value]
end
