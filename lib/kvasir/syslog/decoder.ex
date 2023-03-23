defmodule Kvasir.Syslog.Decoder do
  @moduledoc """
  The decoder is a consumer from the server, it's getting each string from
  the server and providing its decoded form as a producer.
  """
  use GenStage, restart: :transient
  require Logger
  alias Kvasir.Syslog.Parser

  def start_link(opts) do
    GenStage.start_link(__MODULE__, opts)
  end

  @impl GenStage
  @doc false
  def init(opts) do
    producer = opts[:producer] || raise "a producer must be provided"
    {:producer_consumer, [], dispatcher: GenStage.DemandDispatcher, subscribe_to: [producer]}
  end

  @impl GenStage
  @doc false
  def handle_events(events, _from, state) do
    events
    |> Enum.map(fn event ->
      case Parser.parse(event) do
        {:error, reason} ->
          Logger.error("dropping message: #{inspect(reason)}")
          nil

        syslog ->
          syslog
      end
    end)
    |> Enum.reject(&is_nil/1)
    |> then(&{:noreply, &1, state})
  end
end
