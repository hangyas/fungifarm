defmodule Fungifarm.Database.MongoImpl do
  alias Fungifarm.Database.Impl
  @behaviour Impl

  @db :mongo

  @config Application.get_env(:fungifarm, :mongo_conf)
  @collection_prefix @config[:collection_prefix]
  @readonly @config[:readonly]

  def child_spec(_opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def start_link() do
    import Supervisor.Spec

    children = [
      worker(Mongo, [
        [
          name: @db,
          pool_size: 2,
          url: @config[:db_url]
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
  def save(collection, measurement) do
    collection = collection_key(collection)
    unless @readonly do
      Mongo.insert_one(@db, collection, measurement)
    end
  end

  @impl true
  def current(collection) do
    [current] = Mongo.find(@db, collection_key(collection), %{}, sort: %{time: -1}, limit: 1) |> Enum.to_list
    with_atom_keys(current)
  end

  @impl true
  def get_range(collection, from, until) do
    Mongo.find(@db, collection_key(collection),
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
  def min(collection, from, until) do
    [min] = Mongo.find(@db, collection_key(collection), %{}, sort: %{value: 1}, limit: 1) |> Enum.to_list
    with_atom_keys(min)
  end

  @impl true
  def max(collection, from, until) do
    [max] = Mongo.find(@db, collection_key(collection), %{}, sort: %{value: -1}, limit: 1) |> Enum.to_list
    with_atom_keys(max)
  end

  @impl true
  def avg(collection, from, until) do
    # avg aggregation isn't allowed in the free atlas tier
    data = Mongo.find(@db, collection_key(collection),
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

  defp collection_key(collection) do
    collection = case collection do
      str when is_bitstring(str) -> str
      atom when is_atom(atom) ->
        full = Atom.to_string(atom)
        case full do
          "Elixir." <> id -> id
          id -> id
        end
    end

    @collection_prefix <> collection
  end

end
