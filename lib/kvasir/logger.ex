defmodule Kvasir.Logger do
  alias :gen_event, as: GenEvent
  alias Kvasir.Syslog
  alias Kvasir.Syslog.Client

  @behaviour :gen_event

  @impl GenEvent
  def init(__MODULE__) do
    opts = Application.get_env(:logger, __MODULE__)
    {:ok, configure(opts)}
  end

  defp get_ip(address) when is_binary(address) do
    address
    |> to_charlist()
    |> :inet.gethostbyname()
    |> then(fn {:ok, {:hostent, _address, _, :inet, 4, [ip | _]}} -> ip end)
  end

  defp get_ip(address) when is_tuple(address) and tuple_size(address) == 4, do: address

  defp configure(opts) do
    syslog =
      Syslog.new(opts[:rfc] || :rfc5424)
      |> Syslog.set_facility(opts[:facility] || :local1)
      |> Syslog.set_app_name(opts[:app_name] || "kvasir")

    host = opts[:host] || raise "A host configuration is needed for Kvasir.Logger"
    port = opts[:port] || raise "A port configuration is needed for Kvasir.Logger"

    %{
      host: get_ip(host),
      port: port,
      syslog_base: syslog
    }
    |> open_socket()
  end

  defp open_socket(state) do
    opts = [host: state.host, port: state.port]
    {:ok, socket} = Kvasir.Application.start_client(opts)
    Map.put(state, :socket, socket)
  end

  @impl GenEvent
  @doc false
  def handle_call({:configure, opts}, state) do
    if socket = state.socket, do: Client.stop(socket)
    {:ok, :ok, Map.merge(state, configure(opts))}
  end

  defp to_timestamp({date, {h, m, s, ms}}) do
    NaiveDateTime.from_erl!({date, {h, m, s}}, {ms * 1_000, 3})
    |> DateTime.from_naive!("Etc/UTC")
  end

  defp pid_to_string(pid) when is_pid(pid) do
    hd(Regex.run(~r/^#PID<([^>]+)>$/, "#{inspect(pid)}", capture: :all_but_first))
  end

  @impl GenEvent
  @doc false
  def handle_event({_level, gl, {Logger, _message, _timestamp, _metadata}}, state)
      when node(gl) != node() do
    {:ok, state}
  end

  def handle_event({level, gl, {Logger, message, timestamp, metadata}}, state) do
    syslog =
      state.syslog_base
      |> Syslog.set_severity(metadata[:erl_level] || level)
      |> Syslog.set_process_id(pid_to_string(metadata[:pid] || gl))
      |> Syslog.set_message(message)
      |> Syslog.set_timestamp(to_timestamp(timestamp))
      |> Syslog.add_structured_data("metadata", process_metadata(metadata))

    Client.log(state.socket, syslog)
    {:ok, state}
  end

  def handle_event(:flush, state) do
    {:ok, state}
  end

  defp process_metadata(metadata) do
    for {key, value} <- metadata,
        (is_binary(value) or is_number(value)) and
          key not in ~w[erl_level domain gl pid]a,
        into: %{} do
      {to_string(key), to_string(value)}
    end
  end
end
