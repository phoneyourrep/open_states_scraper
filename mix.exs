defmodule OpenStatesScraper.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :open_states_scraper,
      version: @version,
      elixir: "~> 1.5",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {OpenStatesScraper.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:gen_stage, "~> 0.14"},
      {:open_states, "~> 0.1"},
      {:poison, "~> 3.1"}
    ]
  end
end
