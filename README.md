# Statex

Elixir state machine based on [Amazon States Language](https://states-language.net/spec.html)

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `statex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:statex, git: "https://github.com/jmrepetti/statex.git"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/statex](https://hexdocs.pm/statex).


#TODO: Refactor, consider writing input and output (result) into the state, and pass prev_state as input for next state. Instead of transforming input, transform state. If I provide a task with a Result field, this override state output. Maybe for testing purposes.