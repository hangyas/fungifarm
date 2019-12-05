defmodule FarmUnit.Application do
  use Application

  def start(_type, _args) do

    sensors = Application.get_env(:fungifarm, :sensors)
    |> Enum.map(fn {mod, _name} -> mod end)

    children = [
    ] ++ sensors

    opts = [strategy: :one_for_one, name: FarmUnit.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
