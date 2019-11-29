defmodule FungifarmWeb.Application do
  use Application

  def start(_type, _args) do
    children = [
      FungifarmWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: FungifarmWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    FungifarmWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
