defmodule PulletMQTest do
  use ExUnit.Case
  doctest PulletMQ

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

  test "more than one instance can be started" do
    assert {:ok, _pullet} = PulletMQ.start_link(data_dir: mktemp(), queue_id: :test_multiple_q1)
    assert {:ok, _pullet} = PulletMQ.start_link(data_dir: mktemp(), queue_id: :test_multiple_q2)
  end

  test "can't create more then one instance with tha same id" do
    assert {:ok, _pullet} = PulletMQ.start_link(data_dir: mktemp(), queue_id: :test_no_multiple)
    assert {:error, {:already_started, _pid}} = PulletMQ.start_link(data_dir: mktemp(), queue_id: :test_no_multiple)
  end

  test "can push", %{pullet: pullet} do
    assert :ok = PulletMQ.push(pullet, :item)
  end

  test "can send existing item after request", %{pullet: pullet} do
    PulletMQ.push(pullet, :test_item)
    PulletMQ.request(pullet, self())

    assert_receive {:item, :test_item}
  end

  test "can send items pushed after request", %{pullet: pullet} do
    PulletMQ.request(pullet, self())
    PulletMQ.push(pullet, :test_item)

    assert_receive {:item, :test_item}
  end

  test "can handle multiple requests in the right order", %{pullet: pullet} do
    PulletMQ.request(pullet, self())
    PulletMQ.request(pullet, self())

    PulletMQ.push(pullet, :test_item1)
    PulletMQ.push(pullet, :test_item2)
    PulletMQ.push(pullet, :test_item3)

    assert_receive {:item, :test_item1}
    assert_receive {:item, :test_item2}

    PulletMQ.request(pullet, self())

    assert_receive {:item, :test_item3}
  end

  test "can be restored" do
    dir = mktemp()

    {:ok, pullet} = PulletMQ.start_link(data_dir: dir, queue_id: :test_restore)
    PulletMQ.push(pullet, :item)
    :ok = PulletMQ.stop(pullet)

    {:ok, pullet} = PulletMQ.start_link(data_dir: dir, queue_id: :test_restore)
    PulletMQ.request(pullet, self())

    assert_receive {:item, :item}
  end

  test "registers syn name" do
    {:ok, pullet} = PulletMQ.start_link(data_dir: mktemp(), queue_id: :test_syn, process_name: PulletMQTest.TestSyn)
    assert ^pullet = :syn.whereis(PulletMQTest.TestSyn)
  end
end
