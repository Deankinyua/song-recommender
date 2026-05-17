defmodule SongRecommender.MixProject do
  use Mix.Project

  def project do
    [
      app: :song_recommender,
      version: "0.1.0",
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: app_deps() ++ ne3ko_deps() ++ phoenix_deps(),
      dialyzer: [
        # Put the project-level PLT in the priv/ directory (instead of the default _build/ location)
        plt_add_apps: [:ex_unit, :mix],
        plt_file: {:no_warn, "priv/plts/project.plt"}
      ],
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        ci: :test,
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.html": :test
      ],
      name: "Song Recommender",
      source_url: "https://github.com/Deankinyua/song-recommender",
      docs: &docs/0,
      compilers: [:phoenix_live_view] ++ Mix.compilers(),
      listeners: [Phoenix.CodeReloader]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {SongRecommender.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp docs do
    [
      # The main page in the docs
      main: "Song Recommender",
      extras: ["README.md"]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp ne3ko_deps do
    [
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: :test, runtime: false},
      {:mix_audit, "~> 2.1", only: :test, runtime: false},
      {:excoveralls, "~> 0.18", only: :test}
    ]
  end

  defp app_deps do
    [
      {:boltx, "~> 0.0.6"},
      {:nimble_csv, "~> 1.1"},
      {:oban, "~> 2.17"},
      {:testcontainers, "~> 2.3", only: [:test, :dev]}
    ]
  end

  # Type `mix help deps` for examples and options.
  defp phoenix_deps do
    [
      {:phoenix, "~> 1.8.6"},
      {:phoenix_ecto, "~> 4.5"},
      {:ecto_sql, "~> 3.13"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 1.1.0"},
      {:lazy_html, ">= 0.1.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:esbuild, "~> 0.10", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.3", runtime: Mix.env() == :dev},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.2.0",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},
      {:swoosh, "~> 1.16"},
      {:req, "~> 0.5"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 1.0"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.2.0"},
      {:bandit, "~> 1.11"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "assets.setup", "assets.build"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["compile", "tailwind song_recommender", "esbuild song_recommender"],
      "assets.deploy": [
        "tailwind song_recommender --minify",
        "esbuild song_recommender --minify",
        "phx.digest"
      ],
      ci: [
        "deps.unlock --check-unused",
        "deps.audit",
        "format --check-formatted",
        "cmd npx prettier -c .",
        "credo --strict",
        "dialyzer",
        "test --cover --warnings-as-errors"
      ],
      credo: ["credo --strict"],
      prettier: ["cmd npx prettier -w ."]
    ]
  end
end
