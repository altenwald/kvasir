defmodule Kvasir.MixProject do
  use Mix.Project

  def project do
    [
      app: :kvasir,
      description: "Elixir Syslog server, client, and backend for Logger.",
      version: "1.0.0",
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: package(),
      preferred_cli_env: [
        check: :test
      ]
    ]
  end

  defp package do
    [
      name: :kvasir_syslog,
      files: ["lib", "mix.exs", "mix.lock", "README*", "COPYING*"],
      maintainers: ["Manuel Rubio"],
      licenses: ["LGPL-2.1-only"],
      links: %{"GitHub" => "https://github.com/altenwald/kvasir"}
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md"]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def application do
    [
      extra_applications: [:logger],
      mod: {Kvasir.Application, []}
    ]
  end

  defp deps do
    [
      {:gen_stage, "~> 1.1"},
      {:tzdata, "~> 1.1"},

      # only for dev
      {:dialyxir, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:credo, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:doctor, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:ex_check, "~> 0.14", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:mix_audit, ">= 0.0.0", only: [:dev, :test], runtime: false}
    ]
  end
end
