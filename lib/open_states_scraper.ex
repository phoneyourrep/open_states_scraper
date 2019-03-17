defmodule OpenStatesScraper do
  @moduledoc """
  Scraper application that bulk downloads U.S. state legislator data from
  the OpenStates GraphQL API.

  Implemented as a GenStage pipeline for concurrent processing.

  To use the scraper execute the command `MIX_ENV=prod mix run --no-halt`. All of the data will be written
  to the `./data/` directory.
  """
end
