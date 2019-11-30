defmodule FarmUnit.Application do
  use Application

  def start(_type, _args) do
    children = [
      FarmUnit.FakeSensor,
      PubSub,
      {Task.Supervisor, name: FarmUnit.Datasource.SubscribingTasks}
    ]

    opts = [strategy: :one_for_one, name: FarmUnit.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
