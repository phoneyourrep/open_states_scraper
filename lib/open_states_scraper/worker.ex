defmodule OpenStatesScraper.Worker do
  @moduledoc """
  Task that does the scraping and writes the data to disk.
  """

  use Task
  import OpenStates, only: [sigil_q: 2]
  require Logger

  @chambers ~w(legislature upper lower)

  def start_link([], jurisdiction) do
    Task.start_link(__MODULE__, :scrape, [jurisdiction])
  end

  def scrape(jurisdiction) do
    results =
      Enum.reduce(@chambers, [], fn chamber, acc -> [get_people(jurisdiction, chamber) | acc] end)
      |> List.flatten()

    File.write("./data/#{jurisdiction}.json", Poison.encode!(results))
  end

  defp get_people(jurisdiction, chamber) do
    case people_query(jurisdiction, chamber) do
      {:ok, %{body: response}} ->
        response
        |> get_in(["data", "jurisdiction", "organizations", "edges"])
        |> List.first()
        |> get_in(["node", "currentMemberships"])

      {:error, %{body: error}} ->
        error |> IO.inspect() |> Logger.warn()
        Logger.warn(jurisdiction)
        get_people(jurisdiction, chamber)

      {:error, %{reason: reason}} ->
        reason |> IO.inspect() |> Logger.warn()
        Logger.warn(jurisdiction)
        get_people(jurisdiction, chamber)
    end
  end

  defp people_query(jurisdiction, chamber) do
    ~q"""
    {
      jurisdiction(name: "#{jurisdiction}") {
        name
        organizations(first: 1, classification: "#{chamber}") {
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
                    label
                    organization {
                      id
                      name
                      image
                      classification
                    }
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
    """
  end
end
