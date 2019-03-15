defmodule OpenStatesScraper.Jurisdictions do
  @moduledoc """
  This is a GenStage producer that fetches the full list of `jurisdictions` from
  the OpenStates API on init and sends them to the consumer when there is demand.
  """

  use GenStage

  @name __MODULE__

  def start_link([]) do
    GenStage.start_link(@name, :ok, name: @name)
  end

  # def get, do: GenServer.call(@name, :get)

  ## Callbacks

  def init(:ok) do
    {:ok, %{status_code: 200, body: body}} = OpenStates.jurisdictions(attrs: [:name])
    state_names =
      Enum.map(body["data"]["jurisdictions"]["edges"], fn node ->
        node["node"]["name"]
      end)
    {:producer, state_names}
  end

  # def handle_call(:get, _from, state) do
  #   {:reply, state, [], state}
  # end
end
