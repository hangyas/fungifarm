defmodule FarmUnit.Application do
  use Application

  def start(_type, _args) do
    sensors = Application.get_env(:farmunit, :sensors)
    remote = Application.get_env(:farmunit, :fungifarm_node)
    name = Application.get_env(:farmunit, :name)

    unit_metadata = %{
      name: name,
      measurements: "measurements:#{name}"
    }

    children =
      [
        PubSub,
        {
          Uplink.Connector,
          remote: remote, metadata: unit_metadata
        },
        {
          PulletMQ,
          queue_id: :measurements, data_dir: ".pullet/dev", process_name: unit_metadata.measurements
        }
      ] ++ sensors

    Supervisor.start_link(children, strategy: :one_for_one, name: FarmUnit.Supervisor)
  end
end
