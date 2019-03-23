defmodule OpenStatesScraperTest do
  use ExUnit.Case
  doctest OpenStatesScraper.Consumer

  test "reduce_response" do
    response =
      "./test/fixtures/response.json"
      |> File.read!()
      |> Poison.decode!()

    result =
      "./test/fixtures/result.json"
      |> File.read!()
      |> Poison.decode!()

    assert OpenStatesScraper.Consumer.reduce_response(response) == result
  end
end
