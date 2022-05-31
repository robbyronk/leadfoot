defmodule RaceControlWeb.TelemetryLive.View do
  @moduledoc false
  use RaceControlWeb, :live_view
  alias Phoenix.PubSub

  @impl true
  def mount(_params, session, socket) do
    #    file = RaceControl.ReadFile.read("session.forza")
    PubSub.subscribe(RaceControl.PubSub, "session")
    {:ok, assign(socket, :event, %{})}
  end

  def handle_info({:event, event}, socket) do
    {:noreply, assign(socket, :event, event)}
  end
end
