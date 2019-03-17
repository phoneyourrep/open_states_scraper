defmodule OpenStatesScraper.ConsumerSupervisor do
  @moduledoc """
  A consumer supervisor that spawns scraper tasks for each event jurisdiction
  received from the producer. Acts as a worker pool with a maximum of eight concurrent
  processes.
  """

  use ConsumerSupervisor
  alias OpenStatesScraper.{Producer, Consumer}

  @spec start_link([]) :: :ignore | {:error, any()} | {:ok, pid()}
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
      subscribe_to: [{Producer, max_demand: 8}]
    ]

    ConsumerSupervisor.init(children, opts)
  end
end
