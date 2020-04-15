defmodule FarmUnit.MixProject do
  use Mix.Project

  def project do
    [
      app: :farmunit,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {FarmUnit.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:cubdb, "~> 1.0.0-rc.1"},
      {:pubsub, "~> 1.0"},
      {:json, "~> 1.3"},
      {:fungifarm_shared, in_umbrella: true}
    ]
  end
end
