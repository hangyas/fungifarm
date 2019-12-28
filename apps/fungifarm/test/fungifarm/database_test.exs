defmodule Fungifarm.DatabaseTest do
  use ExUnit.Case
  alias Fungifarm.{Database, Sensor, Measurement}

  test "last record is the current" do
    attr = "test-value"
    value = :rand.uniform(100)

    Database.save(
      %Sensor{
        node: "fake-node",
        chip: "fake-chip",
        attribute: attr
      },
      %Measurement{
        time: "just around nowish",
        value: value - 1
      }
    )


    Database.save(
      %Sensor{
        node: "fake-node",
        chip: "fake-chip",
        attribute: attr
      },
      %Measurement{
        time: "just around nowish",
        value: value
      }
    )

    assert value == Database.current(attr)
  end
end
