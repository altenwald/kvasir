# Kvasir
Elixir Syslog server, client, and backend for Logger.

Kvasir's goal is to keep everything we could need regarding Syslog. If we need a client,
a server, or provide a backend for Logger.

## Installation

At the moment there's no hex package available, so you can install it using:

```elixir
def deps do
  [
    {:kvasir, github: "altenwald/kvasir"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
using the command `mix docs`.
