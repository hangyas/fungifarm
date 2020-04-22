defmodule Fungifarm.SharedDatabaseTest do
  import SharedTestCase

  define_tests do
    alias Fungifarm.{Measurement}

    setup %{database: database} do
      database.start_link()

      if database == Fungifarm.Database.MongoImpl do
        Mongo.command(:mongo, %{dropDatabase: 1})
      end

      :ok
    end

    def test_save(database, attr, value, time \\ DateTime.utc_now()) do
      database.save(
        attr,
        %Measurement{
          time: time,
          value: value
        }
      )
    end

    def gen_attr(database) do
      "test-#{System.unique_integer([:positive, :monotonic])}"
    end

    test "last record is the current", %{database: database} do
      attr = gen_attr(database)
      value = :rand.uniform(100)

      test_save(database, attr, value - 1)
      test_save(database, attr, value)

      assert value == database.current(attr).value
    end

    test "return range", %{database: database} do
      attr = gen_attr(database)
      now = DateTime.utc_now()

      day = 60 * 60 * 24

      values =
        1..15
        |> Enum.map(fn i ->
          {now |> DateTime.add(i * day, :second), :rand.uniform(100)}
        end)

      for {time, value} <- values do
        test_save(database, attr, value, time)
      end

      # full range

      from = now |> DateTime.add(1 * day, :second)
      to = now |> DateTime.add(15 * day, :second)

      wrote = values |> Enum.map(fn {_, v} -> v end)
      read = database.get_range(attr, from, to) |> Enum.map(fn e -> e.value end)

      assert read == wrote

      # sub range

      from = now |> DateTime.add(4 * day, :second)
      to = now |> DateTime.add(8 * day, :second)

      wrote = values |> Enum.drop(3) |> Enum.take(5) |> Enum.map(fn {_, v} -> v end)
      read = database.get_range(attr, from, to) |> Enum.map(fn e -> e.value end)

      assert read == wrote
    end

    test "min", %{database: database} do
      attr = gen_attr(database)

      test_save(database, attr, 1)
      test_save(database, attr, 2)
      test_save(database, attr, 0.3)
      test_save(database, attr, 3)

      assert 0.3 == database.min(attr, DateTime.utc_now() |> DateTime.add(-500), DateTime.utc_now()).value
    end


    test "max", %{database: database} do
      attr = gen_attr(database)

      test_save(database, attr, 1)
      test_save(database, attr, 2)
      test_save(database, attr, 0.3)
      test_save(database, attr, 3)

      assert 3 == database.max(attr, DateTime.utc_now() |> DateTime.add(-500), DateTime.utc_now()).value
    end

    test "avg", %{database: database} do
      attr = gen_attr(database)

      test_save(database, attr, 1)
      test_save(database, attr, 2)
      test_save(database, attr, 0.3)
      test_save(database, attr, 3)

      assert 1.575 == database.avg(attr, DateTime.utc_now() |> DateTime.add(-500), DateTime.utc_now())
    end
  end
end

defmodule Fungifarm.Database.InMemoryImplTest do
  use Fungifarm.SharedDatabaseTest, database: Fungifarm.Database.InMemoryImpl
end

defmodule Fungifarm.Database.MongoImplTest do
  use Fungifarm.SharedDatabaseTest, database: Fungifarm.Database.MongoImpl, slow: true
end
