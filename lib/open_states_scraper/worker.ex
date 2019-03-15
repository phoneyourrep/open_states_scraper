defmodule OpenStatesScraper.Worker do
  @moduledoc """
  Task that does the scraping and writes the data to disk.
  """

  use Task

  def start_link([], jurisdiction) do
    Task.start_link(__MODULE__, :scrape, [jurisdiction])
  end

  def scrape(jurisdiction) do
    # TODO: write functions and API queries to loop through all available legislative
    # chambers of the district, collecting and compiling data on legislators and writing them
    # to a static file.
    IO.puts(jurisdiction)
  end
end
