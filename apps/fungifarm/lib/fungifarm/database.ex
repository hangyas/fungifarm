defmodule Fungifarm.Database do
  alias Fungifarm.Database.Impl
  @behaviour Impl

  @impl true
  def get_something(), do: impl().get_something()

  @impl true
  def save(data), do: impl().save(data)

  @impl true
  def current(:temperature) do
    1
  end

  @impl true
  def current(:humidity) do
    1
  end

  defp impl do
    Application.get_env(:fungifarm, :database, __MODULE__.InMemoryImpl)
  end
end
