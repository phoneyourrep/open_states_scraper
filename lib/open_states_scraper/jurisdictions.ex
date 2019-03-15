defmodule OpenStatesScraper.Jurisdictions do
  @moduledoc """
  This is a GenStage producer that fetches the full list of `jurisdictions` from
  the OpenStates API on init and sends them to the consumer when there is demand.
  """

  use GenStage
  alias OpenStatesScraper.ConsumerSupervisor, as: WorkerSup

  @name __MODULE__

  def start_link([]) do
    GenStage.start_link(@name, :ok, name: @name)
  end

  # def get, do: GenServer.call(@name, :get)

  ## Callbacks

  def init(:ok) do
    {:ok, %{status_code: 200, body: body}} = OpenStates.jurisdictions(attrs: [:name])
    File.mkdir("./data")
    state_names =
      Enum.map(body["data"]["jurisdictions"]["edges"], fn node ->
        node["node"]["name"]
      end)
    {:producer, state_names}
  end

  def handle_demand(demand, _state = []) when demand > 0 do
    shutdown_when_complete()
  end

  def handle_demand(demand, state) when demand > 0 do
    jurisdictions = Enum.take(state, demand)
    {:noreply, jurisdictions, Enum.drop(state, demand)}
  end

  # def handle_call(:get, _from, state) do
  #   {:reply, state, [], state}
  # end

  defp shutdown_when_complete do
    case ConsumerSupervisor.count_children(WorkerSup) do
      %{active: 0} ->
        System.halt(0)

      %{active: _} ->
        Process.sleep(500)
        shutdown_when_complete()
    end
  end
end
