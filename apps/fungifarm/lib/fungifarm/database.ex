defmodule Fungifarm.Database do
  alias Fungifarm.Database.Impl
  @behaviour Impl

  def child_spec(opts), do: impl().child_spec(opts)

  @impl true
  def get_something(), do: impl().get_something()

  @impl true
  def save(sensor, measurement), do: impl().save(sensor, measurement)

  @impl true
  def current(attr), do: impl().current(attr)

  @impl true
  def get_range(attr, from, until), do: impl().get_range(attr, from, until)

  defp impl do
    Application.get_env(:fungifarm, :database, __MODULE__.InMemoryImpl)
  end
end
