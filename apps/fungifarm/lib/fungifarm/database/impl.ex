defmodule Fungifarm.Database.Impl do
  alias Fungifarm.{Sensor, Measurement}

  @callback child_spec(any) :: any
  @callback get_something() :: {:ok, [String.t]}
  @callback current(atom) :: {:ok, integer}
  @callback save(Sensor, Measurement) :: :ok | {:error, String.t}
end
