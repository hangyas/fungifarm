defmodule Fungifarm.Database.Impl do
  @callback get_something() :: {:ok, [String.t]}
  @callback save(String.t) :: :ok | {:error, String.t}
end
