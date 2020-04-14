defmodule ConnectorTest do
  use ExUnit.Case

  test "can be started" do
    assert {:ok, _connector} = Uplink.Connector.start_link(remote: node(), metadata: %{msg: "hello"})
  end

end
