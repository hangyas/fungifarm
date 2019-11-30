defmodule FarmUnit.Datasource do
  def subscribe(_farmunit_node, _pid, []) do
  end

  def subscribe(farmunit_node, pid, [topic | tail]) do
    Task.Supervisor.async(
      {FarmUnit.Datasource.SubscribingTasks, farmunit_node},
      PubSub,
      :subscribe,
      [pid, topic]
    )
    subscribe(farmunit_node, pid, tail)
  end

  def publish(topic, msg) do
    PubSub.publish(topic, msg)
  end
end
