defmodule FarmUnitTest do
  use ExUnit.Case
  doctest FarmUnit

  test "greets the world" do
    assert FarmUnit.hello() == :world
  end
end
