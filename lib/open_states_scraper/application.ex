defmodule OpenStatesScraper.Application do
  @moduledoc false

  use Application
  alias OpenStatesScraper.Producer
  alias OpenStatesScraper.ConsumerSupervisor, as: CS

  @env Mix.env()

  def start(_type, _args) do
    IO.puts(@env)
    opts = [strategy: :one_for_one, name: OpenStatesScraper.Supervisor]
    Supervisor.start_link(children(@env), opts)
  end

  def children(:prod) do
    [
      Producer,
      CS
    ]
  end

  def children(_) do
    children(:prod) -- [CS]
  end
end
