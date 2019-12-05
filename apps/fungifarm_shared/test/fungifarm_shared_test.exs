defmodule FungifarmSharedTest do
  use ExUnit.Case
  doctest FungifarmShared

  test "greets the world" do
    assert FungifarmShared.hello() == :world
  end
end
