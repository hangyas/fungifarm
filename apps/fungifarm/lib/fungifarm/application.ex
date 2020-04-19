defmodule Fungifarm.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      Fungifarm.Database,
      Fungifarm.SinkManager
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Fungifarm.Supervisor)
  end
end
