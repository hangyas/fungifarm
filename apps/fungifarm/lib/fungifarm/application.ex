defmodule Fungifarm.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    connect_farm_units()

    children = [
      # worker(Mongo, [
      #   [
      #     name: :mongo,
      #     database: "habzsibot",
      #     pool_size: 2,
      #     url: Application.get_env(:fungifarm, :db_url)
      #   ]
      # TODO add database
      PubSub,
      Fungifarm.DataBroker
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Fungifarm.Supervisor)
  end

  def connect_farm_units() do
    node = Application.get_env(:fungifarm, :farmunit_node)
    Node.connect(node)
  end
end
