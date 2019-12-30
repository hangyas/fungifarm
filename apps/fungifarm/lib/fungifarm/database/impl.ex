defmodule Fungifarm.Database.Impl do
  alias Fungifarm.{Sensor, Measurement}

  @callback save(Sensor.t, Measurement.t) :: :ok | {:error, String.t}
  @callback current(atom) :: {:ok, Measurement.t} | {:error, String.t}
  @callback get_range(atom, DateTime.t, DateTime.t) :: {:ok, [Measurement.t]} | {:error, String.t}
  @callback min(atom, DateTime.t, DateTime.t) :: {:ok, Measurement.t} | {:error, String.t}
  @callback max(atom, DateTime.t, DateTime.t) :: {:ok, Measurement.t} | {:error, String.t}
  @callback avg(atom, DateTime.t, DateTime.t) :: {:ok, Measurement.t} | {:error, String.t}

  @callback get_something() :: {:ok, [String.t]}
end
