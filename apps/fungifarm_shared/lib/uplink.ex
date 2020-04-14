# defmodule Uplink do

#   # Needs existing memento talbe for the message type
#   #
#   # ```
#   # :ok = Memento.Table.create!(Record)
#   # Uplink.send("do something")
#   # ```
#   def send(message) do
#     Memento.transaction!(fn ->
#       Memento.Query.write(%Uplink.Message{msg: message})
#     end)
#   end

#   # you will receive {:mnesia_table_event, {:write, {<type>, <fields...>}, {:tid, <id>, <pid>}}}
#   # messages
#   #
#   # ```
#   # :ok = Memento.Table.create!(Record)
#   # Uplink.subscribe(Record)
#   # ```
#   # def subscribe(queue, pid \\ self()) do
#   #   :mnesia.subscribe({:table, FarmUnit.Record, :simple})
#   # end
# end
