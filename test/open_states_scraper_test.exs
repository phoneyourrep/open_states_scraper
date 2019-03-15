defmodule OpenStatesScraperTest do
  use ExUnit.Case
  doctest OpenStatesScraper

  test "greets the world" do
    assert OpenStatesScraper.hello() == :world
  end
end
