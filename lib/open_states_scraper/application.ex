defmodule OpenStatesScraper.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      OpenStatesScraper.Jurisdictions,
      OpenStatesScraper.ConsumerSupervisor
    ]

    opts = [strategy: :one_for_one, name: OpenStatesScraper.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
