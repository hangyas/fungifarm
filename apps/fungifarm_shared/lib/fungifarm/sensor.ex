defmodule Fungifarm.Sensor do
  @moduledoc ~S"""
  sensor information, constant between measurements
  """

  defstruct [:node, :chip, :attribute]
end
