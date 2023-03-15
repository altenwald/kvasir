defmodule Kvasir.Consumer do
  use GenStage

  def start_link(producer) do
    GenStage.start_link(__MODULE__, [self(), producer])
  end

  def init([parent_pid, producer]) do
    {:consumer, parent_pid, subscribe_to: [producer]}
  end

  def handle_events(events, _from, parent_pid) do
    send(parent_pid, events)
    {:noreply, [], parent_pid}
  end
end
