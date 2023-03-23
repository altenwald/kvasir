defmodule Kvasir.Consumer do
  @moduledoc """
  This consumer was designed for consuming events from GenStage
  and send them back to the process that started this consumer.
  The typical use case is for testing.
  """
  use GenStage

  @doc """
  Starts the consumer.
  """
  def start_link(producer) do
    GenStage.start_link(__MODULE__, [self(), producer])
  end

  @impl GenStage
  @doc false
  def init([parent_pid, producer]) do
    {:consumer, parent_pid, subscribe_to: [producer]}
  end

  @impl GenStage
  @doc false
  def handle_events(events, _from, parent_pid) do
    send(parent_pid, events)
    {:noreply, [], parent_pid}
  end
end
