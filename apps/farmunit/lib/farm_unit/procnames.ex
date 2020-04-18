defmodule FarmUnit.Procnames do

  @moduledoc ~S"""
  For unit specific :syn names
  """

  def measurements_queue() do
    "measurements:#{name()}"
  end

  def sensor_subscribers_group() do
    "sensor_subscribers:#{name()}"
  end

  def name() do
    Application.get_env(:farmunit, :name)
  end

end
