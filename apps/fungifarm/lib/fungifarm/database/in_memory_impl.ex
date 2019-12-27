defmodule Fungifarm.Database.InMemoryImpl do
  alias Fungifarm.Database.Impl
  @behaviour Impl

  @impl Impl
  def get_something(), do: {:ok, ["some data"]}

  @impl Impl
  def current(:temperature) do
    0
  end

  @impl Impl
  def current(:humidity) do
    0
  end

  @impl Impl
  def save(_data), do: :ok
end
