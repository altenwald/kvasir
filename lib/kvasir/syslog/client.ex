defmodule Kvasir.Syslog.Client do
  @moduledoc """
  Creates a syslog client. It requires a port from where we are going
  to send the message to the syslog server. It could be useful to create
  a pool of clients to send the syslog messages.
  """
  use GenServer, restart: :transient
  require Logger
  alias Kvasir.Syslog

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def stop(pid), do: GenServer.stop(pid)

  def log(pid, %Syslog{} = syslog) do
    data = to_string(syslog)
    GenServer.cast(pid, {:log, data})
  end

  @impl GenServer
  def init(opts) do
    port = opts[:port]
    host = opts[:host]
    {:ok, socket} = :gen_udp.open(0)
    :ok = :gen_udp.connect(socket, host, port)
    {:ok, socket}
  end

  @impl GenServer
  def terminate(_reason, socket) do
    :gen_udp.close(socket)
    :ok
  end

  @impl GenServer
  def handle_info({:udp, socket, _ip, _port, message}, socket) do
    Logger.info("received unexpected message: #{inspect(message)}")
    {:noreply, socket}
  end

  def handle_info({:udp_error, socket, reason}, socket) do
    Logger.error("closing due to UDP error: #{inspect(reason)}")
    {:stop, reason, socket}
  end

  @impl GenServer
  def handle_cast({:log, data}, socket) do
    :ok = :gen_udp.send(socket, data)
    {:noreply, socket}
  end
end
