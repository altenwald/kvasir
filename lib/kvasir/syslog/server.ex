defmodule Kvasir.Syslog.Server do
  @moduledoc """
  Creates an UDP server for listening for syslog messages.
  The default port for listening for new incoming messages is 5544.
  See `start_link/1` for checking the options you can use.
  """
  use GenStage, restart: :transient

  @default_port 5544

  @doc """
  Starts the syslog server. You can provide a keyword list of
  options:

  - `port` to indicate the port where the server will start listening.
  """
  def start_link(opts) do
    GenStage.start_link(__MODULE__, opts)
  end

  @doc """
  Get the port where the syslog server is listening.
  """
  @spec get_port(GenServer.server()) :: pos_integer()
  def get_port(pid) do
    GenStage.call(pid, :port)
  end

  @doc """
  Stops the server. It's useful if we need starting a server out of a supervisor,
  or we need the server will be restarted inside of the supervisor.
  """
  @spec stop(GenServer.server()) :: :ok
  defdelegate stop(pid), to: GenStage

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
