defmodule FarmUnit.Application do
  use Application

  def start(_type, _args) do

    sensors = Application.get_env(:fungifarm, :sensors)
    |> Enum.map(fn {mod, args} -> {mod, args} end)

    children = [
      PubSub
    ] ++ sensors

    Supervisor.start_link(children, strategy: :one_for_one, name: FarmUnit.Supervisor)
  end
end
