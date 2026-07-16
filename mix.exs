defmodule CrucibleFeedback.MixProject do
  use Mix.Project

  @version "0.2.0"
  @source_url "https://github.com/North-Shore-AI/crucible_feedback"

  def project do
    [
      app: :crucible_feedback,
      version: @version,
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "CrucibleFeedback",
      description: "Feedback collection, drift detection, and active learning for ML pipelines",
      source_url: @source_url,
      homepage_url: @source_url,
      docs: docs(),
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :telemetry],
      mod: {CrucibleFeedback.Application, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_env), do: ["lib"]

  defp deps do
    [
      # Database
      {:ecto_sql, "~> 3.14"},
      {:postgrex, "~> 0.22.3"},

      # JSON
      {:jason, "~> 1.4"},

      # Statistics (for drift detection)
      {:nx, "~> 0.12.1"},
      {:scholar, "~> 0.4.2", optional: true},

      # Crucible integration (optional)
      {:crucible_framework, "~> 0.5.2"},
      {:crucible_ir, "~> 0.3.0", override: true},

      # Telemetry
      {:telemetry, "~> 1.4"},

      # Testing
      {:mox, "~> 1.2", only: :test},
      {:ex_machina, "~> 2.8", only: :test},

      # Quality
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.40.3", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      main: "readme",
      name: "CrucibleFeedback",
      source_ref: "v#{@version}",
      source_url: @source_url,
      homepage_url: @source_url,
      extras: ["README.md", "CHANGELOG.md", "LICENSE"],
      assets: %{"assets" => "assets"},
      logo: "assets/crucible_feedback.svg"
    ]
  end

  defp package do
    [
      name: "crucible_feedback",
      description: "Feedback collection, drift detection, and active learning for ML pipelines",
      files: ~w(README.md CHANGELOG.md mix.exs LICENSE lib assets),
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Online documentation" => "https://hexdocs.pm/crucible_feedback"
      },
      maintainers: ["nshkrdotcom"]
    ]
  end
end
