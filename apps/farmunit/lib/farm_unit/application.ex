defmodule FarmUnit.Application do
  use Application

  alias FarmUnit.{ MeasurementsLoader, Procnames, Uplink }

  def start(_type, _args) do
    remote = Application.get_env(:farmunit, :fungifarm_node)
    name = Application.get_env(:farmunit, :name)

    unit_metadata = %{
      name: name,
      measurements: Procnames.measurements_queue()
    }

    sensors =
      Application.get_env(:farmunit, :sensors)
      |> Enum.map(fn {mod, conf} ->
        {mod, conf ++ [message_queue: unit_metadata.measurements]}
      end)

    children =
      [
        {
          Uplink,
          remote: remote, metadata: unit_metadata
        },
        {
          PulletMQ,
          queue_id: :measurements,
          data_dir: ".pullet/dev",
          process_name: Procnames.measurements_queue()
        },
        MeasurementsLoader # loads every measurements to a PulletMQ queue
      ] ++ sensors

    Supervisor.start_link(children, strategy: :one_for_one, name: FarmUnit.Supervisor)
  end
end
