defmodule Fungifarm.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      # worker(Mongo, [
      #   [
      #     name: :mongo,
      #     database: "habzsibot",
      #     pool_size: 2,
      #     url: Application.get_env(:fungifarm, :db_url)
      #   ]
      # Fungifarm.Database,
      # Fungifarm.FarmunitRegistry,
      # Uplink.Satelite
      Uplink.Satelite
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Fungifarm.Supervisor)
  end
end
