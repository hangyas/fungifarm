defmodule Fungifarm.Database do
  alias Fungifarm.Database.Impl
  @behaviour Impl

  @impl true
  def child_spec(opts), do: impl().child_spec(opts)

  @impl true
  def get_something(), do: impl().get_something()

  @impl true
  def save(sensor, measurement), do: impl().save(sensor, measurement)

  @impl true
  def current(attr), do: impl().current(attr)

  defp impl do
    Application.get_env(:fungifarm, :database, __MODULE__.InMemoryImpl)
  end
end
