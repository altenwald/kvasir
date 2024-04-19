defmodule Kvasir.Application do
  @moduledoc false

  use Application
  alias Kvasir.Syslog.{Client, Decoder, Server}

  @impl true
  @doc false
  def start(_type, _args) do
    children = [
      {DynamicSupervisor, strategy: :one_for_one, name: Client.Supervisor},
      {DynamicSupervisor, strategy: :one_for_one, name: Server.Supervisor},
      {DynamicSupervisor, strategy: :one_for_one, name: Decoder.Supervisor}
    ]

    opts = [strategy: :one_for_one, name: Kvasir.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @doc """
  Start a syslog server under the Server supervisor. The options provided
  as the first parameter could be consulted in
  `Kvasir.Syslog.Server.start_link/1`.
  """
  def start_server(opts) do
    DynamicSupervisor.start_child(Server.Supervisor, {Server, opts})
  end

  @doc """
  Start a syslog client under the Client supervisor. The options provided
  as the first parameter could be consulted in
  `Kvasir.Syslog.Client.start_link/1`.
  """
  def start_client(opts) do
    DynamicSupervisor.start_child(Client.Supervisor, {Client, opts})
  end

  @doc """
  Start a syslog decoder under the Decoder supervisor. The options provided
  as the first parameter could be consulted in
  `Kvasir.Syslog.Decoder.start_link/1`.
  """
  def start_decoder(opts) do
    DynamicSupervisor.start_child(Decoder.Supervisor, {Decoder, opts})
  end
end
