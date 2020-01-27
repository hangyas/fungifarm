defmodule Fungifarm.Database.MongoImpl do
  alias Fungifarm.Database.Impl
  @behaviour Impl

  @db :mongo
  @collection_prefix Application.get_env(:fungifarm, :collection_prefix)
  @readonly Application.get_env(:fungifarm, :readonly, false)

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def start_link(_args) do
    import Supervisor.Spec

    children = [
      worker(Mongo, [
        [
          name: @db,
          pool_size: 2,
          url: Application.get_env(:fungifarm, :db_url)
        ]
      ])
    ]

    Supervisor.start_link(children,
      strategy: :one_for_one,
      name: Fungifarm.Database.MongoImpl.Supervisor
    )
  end

  # @impl true
  # def get_something(), do: impl().get_something()

  @impl true
  def save(sensor, measurement) do
    unless @readonly do
      Mongo.insert_one(@db, @collection_prefix <> "_" <> sensor.attribute, measurement)
    end
  end

  @impl true
  def current(attr) do
    [current] = Mongo.find(@db, @collection_prefix <> "_" <> attr, %{}, sort: %{time: 1}, limit: 1) |> Enum.to_list
    with_atom_keys(current)
  end

  @impl true
  def get_range(attr, from, until) do
    Mongo.find(@db, @collection_prefix <> "_" <> attr,
      %{time: %{
        "$lte": until,
        "$gte": from
        }
      }
    )
    |> Enum.to_list
    |> with_atom_keys
  end

  @impl true
  def min(attr, from, until) do
    [min] = Mongo.find(@db, @collection_prefix <> "_" <> attr, %{}, sort: %{value: 1}, limit: 1) |> Enum.to_list
    with_atom_keys(min)
  end

  @impl true
  def max(attr, from, until) do
    [max] = Mongo.find(@db, @collection_prefix <> "_" <> attr, %{}, sort: %{value: -1}, limit: 1) |> Enum.to_list
    with_atom_keys(max)
  end

  @impl true
  def avg(attr, from, until) do
    # avg aggregation isn't allowed in the free atlas tier
    data = Mongo.find(@db, @collection_prefix <> "_" <> attr,
      %{time: %{
        "$lte": until,
        "$gte": from
        }
      }
    )
    |> Enum.to_list
    |> Enum.map(fn m -> m["value"] end)

    Enum.sum(data) / length(data)
  end

  defp with_atom_keys(maps) when is_list(maps) do
    Enum.map(maps, &with_atom_keys/1)
  end

  defp with_atom_keys(map) do
     for {key, val} <- map, into: %{} do
      if is_binary(key) do
        {String.to_existing_atom(key), val}
      else
        {key, val}
      end
    end
  end

end
