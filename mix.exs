defmodule Fungifarm.Umbrella.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: [
        farmunit: [
          version: "0.0.1",
          applications: [
            farmunit: :permanent
          ],
          include_erts: false,
          cookie: File.read!("cookie")
        ],
        fat_farmunit: [
          version: "0.0.1",
          applications: [
            farmunit: :permanent,
            fungifarm: :permanent,
            fungifarm_web: :permanent,
            fungifarm_shared: :permanent
          ],
          include_erts: false,
          cookie: File.read!("cookie")
        ]
      ]
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options.
  #
  # Dependencies listed here are available only for this project
  # and cannot be accessed from applications inside the apps folder
  defp deps do
    []
  end
end
