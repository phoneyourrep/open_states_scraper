# OpenStatesScraper

## Installation

Make sure you have `Elixir ~> 1.5` and Erlang/OTP installed. Clone this repository and configure your [OpenStates API key](https://openstates.org/api/register/) as an environment variable with the name `"OPENSTATES_API_KEY"`. Alternatively you can configure the key in your `config.exs` file:

```elixir
config :open_states, api_key: "xxxxxxxxxxxxxxxxx"
``` 

Then run:

```bash
mix deps.get && mix test
mix run --no-halt
```