defmodule OpenStatesScraper.ConsumerSupervisor do
  @moduledoc """
  A consumer supervisor that spawns scraper tasks for each jurisdiction.
  """

  use ConsumerSupervisor
  alias OpenStatesScraper.{Producer, Consumer}

  def start_link([]) do
    ConsumerSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  ## Callbacks

  def init(:ok) do
    children = [
      Consumer
    ]

    opts = [
      strategy: :one_for_one,
      subscribe_to: [{Producer, max_demand: 4}]
    ]

    ConsumerSupervisor.init(children, opts)
  end
end
