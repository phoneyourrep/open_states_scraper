defmodule OpenStatesScraper.Consumer do
  @moduledoc """
  Task that scrapes legislator data for each jurisdiction and writes the data to disk.
  """

  use Task
  require Logger

  @type jurisdiction :: String.t()

  @spec start_link([], jurisdiction) :: {:ok, pid()}
  def start_link([], jurisdiction) do
    Task.start_link(__MODULE__, :scrape, [jurisdiction])
  end

  @spec scrape(jurisdiction) :: :ok
  def scrape(jurisdiction) do
    results = get_people(jurisdiction)
    File.write("./data/#{to_snakecase(jurisdiction)}.json", Poison.encode!(results, pretty: true))
    IO.puts("Scraped #{jurisdiction}")
  end

  @doc """
  Converts string to snakecase.

  Very limited scope, only parses spaces.

  ## Examples

      iex> OpenStatesScraper.Consumer.to_snakecase("Make Me Snake Case")
      "make_me_snake_case"
  """
  @spec to_snakecase(binary()) :: binary()
  def to_snakecase(jurisdiction) do
    jurisdiction
    |> String.downcase()
    |> String.split(" ")
    |> Enum.join("_")
  end

  def get_people(jurisdiction) do
    case people_query(jurisdiction) do
      {:ok, %{body: response}} ->
        reduce_response(response)

      {:error, %{body: error}} ->
        error |> IO.inspect() |> Logger.warn()
        Logger.warn(jurisdiction)
        Process.sleep(500)
        get_people(jurisdiction)
    end
  end

  def reduce_response(response) do
    response
    |> get_in(["data", "jurisdiction", "organizations", "edges"])
    |> Enum.reduce([], fn edges, acc ->
      [get_in(edges, ["node", "currentMemberships"]) | acc]
    end)
    |> List.flatten()
  end

  def people_query(jurisdiction) do
    OpenStates.query(
      """
      {
        jurisdiction(name: "#{jurisdiction}") {
          name
          organizations(first: 3, classification: ["lower", "upper", "legislature"]) {
            edges {
              node {
                name
                currentMemberships {
                  person {
                    id
                    name
                    familyName
                    givenName
                    image
                    links {
                      url
                    }
                    contactDetails {
                      type
                      value
                      note
                    }
                    sources {
                      url
                    }
                    party: currentMemberships(classification: "party") {
                      organization {
                        id
                        name
                        classification
                      }
                    }
                    chamber: currentMemberships(classification: ["upper", "lower", "legislature"]) {
                      organization {
                        id
                        name
                        classification
                        parent {
                          name
                        }
                      }
                      post {
                        role
                        label
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
      """,
      connection_opts: [timeout: :infinity, recv_timeout: :infinity]
    )
  end
end
