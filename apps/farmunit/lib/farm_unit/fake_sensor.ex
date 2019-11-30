defmodule FarmUnit.FakeSensor do
  use Task

  @topic :fake_sensor_data
  @update_interval 1_000

  def start_link(_arg) do
    Task.start_link(&loop/0)
  end

  def loop() do
    receive do
      # not doing anything with messages
    after
      # receive timeout
      @update_interval ->
        emmit_results()
        loop()
    end
  end

  defp emmit_results() do
    FarmUnit.Datasource.publish(@topic, {:sensor_update, %{name: "vmi", value: :rand.uniform(100)}})
  end
end
