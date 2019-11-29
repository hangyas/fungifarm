defmodule Fungifarm.Database do

  def get_something() do
    Mongo.find(:mongo, "alerts", %{})
    |> Enum.to_list()
    |> Enum.map(fn e -> e["text"] end)
  end

end
