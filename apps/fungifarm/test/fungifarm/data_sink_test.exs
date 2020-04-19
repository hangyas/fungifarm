defmodule Fungifarm.DataSinkTest do
  use ExUnit.Case

  alias Fungifarm.{Measurement, DataSink, Database}

  def mktemp() do
    tmp_dir = :os.cmd('mktemp -d') |> List.to_string() |> String.trim() |> String.to_charlist()

    on_exit(fn ->
      with {:ok, files} <- File.ls(tmp_dir) do
        for file <- files, do: File.rm(Path.join(tmp_dir, file))
      end

      :ok = File.rmdir(tmp_dir)
    end)

    tmp_dir
  end

  setup do
    queue_id = "queue_#{System.unique_integer([:positive, :monotonic])}" |> String.to_atom()

    {:ok, pullet} = PulletMQ.start_link(data_dir: mktemp(), queue_id: queue_id)

    {:ok, pullet: pullet}
  end

  test "pipes to db", %{pullet: pullet} do
    start_time = DateTime.utc_now()

    PulletMQ.push(pullet, {%Measurement{time: DateTime.utc_now(), value: 1}, [id: "test-sink-1"]})

    _sink = DataSink.start_link(pullet)

    PulletMQ.push(pullet, {%Measurement{time: DateTime.utc_now(), value: 2}, [id: "test-sink-1"]})
    PulletMQ.push(pullet, {%Measurement{time: DateTime.utc_now(), value: 3}, [id: "test-sink-1"]})

    Process.sleep(100)
    assert 3 == length(Database.get_range("test-sink-1", start_time, DateTime.utc_now()))
  end

end
