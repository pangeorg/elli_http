defmodule Elli.MixProject do
  use Mix.Project

  def project do
    [
      app: :elli,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "A simple HTTP server implementation in Elixir",
      package: package(),
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.29", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      name: "elli",
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/pangeorg/elli_http"}
    ]
  end

  defp docs do
    [
      main: "Elli",
      extras: ["Readme.md"]
    ]
  end
end
