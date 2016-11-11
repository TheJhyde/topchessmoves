defmodule TopChessMoves.Mixfile do
  use Mix.Project

  def project do
    [app: :top_chess_moves,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [applications: [:logger, :extwitter]]
  end

  defp deps do
    [ {:oauth, github: "tim/erlang-oauth"},
      {:extwitter, "~> 0.7.2"}]
  end
end
