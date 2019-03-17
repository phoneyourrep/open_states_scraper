defmodule OpenStatesScraper.Consumer do
  @moduledoc """
  Task that does the scraping and writes the data to disk.
  """

  use Task
  require Logger

  def start_link([], jurisdiction) do
    Task.start_link(__MODULE__, :scrape, [jurisdiction])
  end

  def scrape(jurisdiction) do
    results = get_people(jurisdiction)
    File.write("./data/#{to_snakecase(jurisdiction)}.json", Poison.encode!(results))
    IO.puts("Scraped #{jurisdiction}")
  end

  defp to_snakecase(jurisdiction) do
    jurisdiction
    |> String.downcase()
    |> String.split(" ")
    |> Enum.join("_")
  end

  defp get_people(jurisdiction) do
    case people_query(jurisdiction) do
      {:ok, %{body: response}} ->
        response
        |> get_in(["data", "jurisdiction", "organizations", "edges"])
        |> Enum.reduce([], fn edges, acc -> [get_in(edges, ["node", "currentMemberships"]) | acc] end)
        |> List.flatten()

      {:error, %{body: error}} ->
        error |> IO.inspect() |> Logger.warn()
        Logger.warn(jurisdiction)
        Process.sleep(500)
        get_people(jurisdiction)
    end
  end

  def people_query(jurisdiction) do
    OpenStates.query("""
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
                  sortName
                  familyName
                  givenName
                  image
                  birthDate
                  deathDate
                  identifiers {
                    identifier
                    scheme
                  }
                  otherNames {
                    name
                    note
                    startDate
                    endDate
                  }
                  links {
                    url
                  }
                  contactDetails {
                    type
                    value
                    note
                    label
                  }
                  sources {
                    url
                  }
                  createdAt
                  updatedAt
                  extras
                  currentMemberships {
                    id
                    personName
                    organization {
                      id
                      name
                      classification
                    }
                    post {
                      id
                      label
                      role
                      startDate
                      endDate

                    }
                    label
                    role
                    startDate
                    endDate
                  }
                }
              }
            }
          }
        }
      }
    }
    """, connection_opts: [timeout: :infinity, recv_timeout: :infinity])
  end
end