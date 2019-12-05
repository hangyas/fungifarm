defmodule FarmUnit.Sensor.Impl do
  @callback attributes() :: [atom]
  # @callback save(String.t) :: :ok | {:error, String.t}
end
