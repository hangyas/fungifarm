defmodule Fungifarm.Database.Impl do
  @callback get_something() :: {:ok, [String.t]}
  @callback current(atom) :: {:ok, integer}
  @callback save(String.t) :: :ok | {:error, String.t}
end
