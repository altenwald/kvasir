defmodule Kvasir.Syslog.Server do
  use GenStage, restart: :transient

  @default_port 5544

  def start_link(opts) do
    GenStage.start_link(__MODULE__, opts)
  end

  def get_port(pid) do
    GenStage.call(pid, :port)
  end

  @impl GenStage
  @doc false
  def init(opts) do
    port = opts[:port] || @default_port
    {:ok, socket} = :gen_udp.open(port, [:binary])
    {:producer, socket, dispatcher: GenStage.DemandDispatcher}
  end

  @impl GenStage
  @doc false
  def terminate(_reason, socket) do
    :gen_udp.close(socket)
    :ok
  end

  @impl GenStage
  @doc false
  def handle_info({:udp, socket, _ip, _port, message}, socket) do
    {:noreply, [message], socket}
  end

  @impl GenStage
  @doc false
  def handle_call(:port, _from, socket) do
    {:reply, :inet.port(socket), [], socket}
  end

  @impl GenStage
  @doc false
  def handle_demand(_demand, state) do
    {:noreply, [], state}
  end
end
