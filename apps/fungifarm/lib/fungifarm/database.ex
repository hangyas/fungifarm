defmodule Fungifarm.Database do
  alias Fungifarm.Database.Impl
  @behaviour Impl

  def child_spec(opts), do: impl().child_spec(opts)

  @impl true
  def get_something(), do: impl().get_something()

  @impl true
  def save(collection, measurement), do: impl().save(collection, measurement)

  @impl true
  def current(attr), do: impl().current(attr)

  @impl true
  def get_range(attr, from, until), do: impl().get_range(attr, from, until)

  @impl true
  def min(attr, from, until), do: impl().min(attr, from, until)

  @impl true
  def max(attr, from, until), do: impl().max(attr, from, until)

  @impl true
  def avg(attr, from, until), do: impl().avg(attr, from, until)

  defp impl do
    Application.get_env(:fungifarm, :database, Application.get_env(:fungifarm, :db_impl))
  end
end
