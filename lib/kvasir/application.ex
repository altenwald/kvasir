defmodule Kvasir.Application do
  @moduledoc false

  use Application
  alias Kvasir.Syslog.{Client, Decoder, Server}

  @impl true
  def start(_type, _args) do
    children = [
      {DynamicSupervisor, strategy: :one_for_one, name: Client.Supervisor},
      {DynamicSupervisor, strategy: :one_for_one, name: Server.Supervisor},
      {DynamicSupervisor, strategy: :one_for_one, name: Decoder.Supervisor}
    ]

    opts = [strategy: :one_for_one, name: Kvasir.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def start_server(opts) do
    DynamicSupervisor.start_child(Server.Supervisor, {Server, opts})
  end

  def start_client(opts) do
    DynamicSupervisor.start_child(Client.Supervisor, {Client, opts})
  end

  def start_decoder(opts) do
    DynamicSupervisor.start_child(Decoder.Supervisor, {Decoder, opts})
  end
end
