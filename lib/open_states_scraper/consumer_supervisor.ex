defmodule OpenStatesScraper.ConsumerSupervisor do
  @moduledoc """
  A consumer supervisor that spawns scraper tasks for each jurisdiction.
  """

  use ConsumerSupervisor
  alias OpenStatesScraper.{Jurisdictions, Worker}

  def start_link([]) do
    ConsumerSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  ## Callbacks

  def init(:ok) do
    children = [
      Worker
    ]

    opts = [
      strategy: :one_for_one,
      subscribe_to: [{Jurisdictions, max_demand: 4}]
    ]

    ConsumerSupervisor.init(children, opts)
  end
end
