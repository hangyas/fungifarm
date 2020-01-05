defmodule Fungifarm.Uplink do

  # def farmunits() do
  #   # later might return units based on health check
  #   [Application.get_env(:fungifarm, :farmunit_node)]
  # end

  def subscribe(node, topic, pid \\ self()) do
    GenServer.cast({PubSub, node}, {:subscribe, %{topic: topic, pid: pid}})
  end

end
