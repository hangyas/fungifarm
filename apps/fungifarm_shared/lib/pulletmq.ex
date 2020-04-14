defmodule PulletMQ do
  @moduledoc ~S"""
  Minimalistic, persistent, deliver at-most-once message queue for durable network communicaiton

  Messages are queued on the sender, the receiver requests the first element and receives it
  as soon as it's available

  Required options:
    - queue_id
    - data_dir
  Optional:
    - process_name name to be registered on syn
  """

  use GenServer

  @initial_state %{
    config: %{},
    cub: nil,
    requests: []
  }

  @doc ~S"""
  Required options:
    - queue_id
    - data_dir
  Optional:
    - process_name name to be registered on syn
  """
  def start_link(opts) do
    state =
      @initial_state
      |> Map.put(:config, Map.new(opts))

    with {:ok, pid} <- GenServer.start_link(__MODULE__, state, name: opts[:queue_id]) do
      if state.config[:process_name] != nil do
        :syn.register(state.config[:process_name], pid)
      end
      {:ok, pid}
    else
      error -> error
    end
  end

  # -- frontend --

  @doc ~S"""
  push item to the end of the queue
  """
  def push(pullet, item) do
    GenServer.call(pullet, {:push, item})
  end

  @doc ~S"""
  request the first item from the queue
  the item will be sent to the destionation process as {:item, item} and removed from the queue
  """
  def request(pullet, destionation \\ self()) do
    GenServer.call(pullet, {:request, destionation})
  end

  def stop(pullet, reason \\ :normal, timeout \\ :infinity) do
    GenServer.stop(pullet, reason, timeout)
  end

  # -- backend --

  def init(state) do
    # if any of these dies, the full queue will die, which is fine for now
    {:ok, cub_db} = CubDB.start_link(data_dir: state.config.data_dir)
    {:ok, cub_q} = CubQ.start_link(db: cub_db, queue: state.config.queue_id)

    state =
      state
      |> Map.put(:cub_db, cub_db)
      |> Map.put(:queue, cub_q)

    {:ok, state}
  end

  def handle_call({:push, item}, _from, state) do
    with {req, requests_tail} <- pop_request(state.requests) do
      answer_request(req, item)

      state =
        state
        |> Map.put(:requests, requests_tail)

      {:reply, :ok, state}
    else
      nil ->
        :ok = CubQ.enqueue(state.queue, item)

        {:reply, :ok, state}
    end
  end

  def handle_call({:request, destionation}, _from, state) do
    with {:ok, item} <- CubQ.dequeue(state.queue) do
      # send immeditaly
      answer_request(destionation, item)
      {:reply, :ok, state}
    else
      nil ->
        # subscribe for push event
        state =
          state
          |> Map.put(:requests, state.requests ++ [destionation])

        {:reply, :ok, state}
    end
  end

  # -- private --

  # pops the first request which is stil alive
  # returns as {request, requests_tail}
  # TODO maybe move this into a state struct

  defp pop_request([]), do: nil

  defp pop_request(requests) do
    [req | tail] = requests

    if :rpc.call(node(req), Process, :alive?, [ req ]) do
      {req, tail}
    else
      pop_request(tail)
    end
  end

  defp answer_request(destionation, item) do
    send(destionation, {:item, item})
  end
end
