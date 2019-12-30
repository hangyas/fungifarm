defmodule Fungifarm.DatabaseTest do
  use ExUnit.Case
  alias Fungifarm.{Database, Sensor, Measurement}

  def test_save(attr, value, time \\ DateTime.utc_now()) do
    Database.save(
      %Sensor{
        node: "fake-node",
        chip: "fake-chip",
        attribute: attr
      },
      %Measurement{
        time: time,
        value: value
      }
    )
  end

  def gen_attr(), do: "test-#{System.unique_integer([:positive, :monotonic])}"

  test "last record is the current" do
    attr = gen_attr()
    value = :rand.uniform(100)

    test_save(attr, value - 1)
    test_save(attr, value)

    assert value == Database.current(attr).value
  end

  test "return range" do
    attr = gen_attr()
    now = DateTime.utc_now()

    day = 60 * 60 * 24

    values =
      1..15
      |> Enum.map(fn i ->
        {now |> DateTime.add(i * day, :second), :rand.uniform(100)}
      end)

    for {time, value} <- values do
      test_save(attr, value, time)
    end

    # full range

    from = now |> DateTime.add(1 * day, :second)
    to = now |> DateTime.add(15 * day, :second)

    wrote = values |> Enum.map(fn {_, v} -> v end)
    read = Database.get_range(attr, from, to) |> Enum.map(fn e -> e.value end)

    assert read == wrote

    # sub range

    from = now |> DateTime.add(4 * day, :second)
    to = now |> DateTime.add(8 * day, :second)

    wrote = values |> Enum.drop(3) |> Enum.take(5) |> Enum.map(fn {_, v} -> v end)
    read = Database.get_range(attr, from, to) |> Enum.map(fn e -> e.value end)

    assert read == wrote
  end

  test "min" do
    attr = gen_attr()

    test_save(attr, 1)
    test_save(attr, 2)
    test_save(attr, 0.3)
    test_save(attr, 3)

    assert 0.3 == Database.min(attr, DateTime.utc_now() |> DateTime.add(-500), DateTime.utc_now()).value
  end


  test "max" do
    attr = gen_attr()

    test_save(attr, 1)
    test_save(attr, 2)
    test_save(attr, 0.3)
    test_save(attr, 3)

    assert 3 == Database.max(attr, DateTime.utc_now() |> DateTime.add(-500), DateTime.utc_now()).value
  end

  test "avg" do
    attr = gen_attr()

    test_save(attr, 1)
    test_save(attr, 2)
    test_save(attr, 0.3)
    test_save(attr, 3)

    assert 1.575 == Database.avg(attr, DateTime.utc_now() |> DateTime.add(-500), DateTime.utc_now())
  end
end
