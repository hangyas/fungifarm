defmodule SateliteTest do
  use ExUnit.Case

  alias Uplink.Satelite

  setup do
    assert {:ok, satelite} = Satelite.start_link()

    {:ok, satelite: satelite}
  end

  test "uplniks can be added", %{satelite: satelite} do
    metadata2 = %{msg: "hello"}
    metadata1 = %{msg: "world"}
    n = node()

    assert :ok = Satelite.add_uplink(n, n, metadata1)
    assert [{^n, ^metadata1}] =  Satelite.get_uplinks()

    assert :ok = Satelite.add_uplink(n, n, metadata2)
    assert [{^n, ^metadata1}, {^n, ^metadata2}] =  Satelite.get_uplinks()
  end

end
