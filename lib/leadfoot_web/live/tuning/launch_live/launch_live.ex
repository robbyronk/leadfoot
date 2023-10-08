defmodule LeadfootWeb.Tuning.LaunchLive do
  @moduledoc false
  use LeadfootWeb, :live_view

  alias Leadfoot.Session.Session
  alias Phoenix.PubSub

  @initial_state %{
    status: :stop,
    g_force: 0,
    current_race_time: 0,
    runs: []
  }

  @impl true
  def mount(_params, _session, socket) do
    user_id = socket.assigns.current_user.id

    if connected?(socket) do
      PubSub.subscribe(Leadfoot.PubSub, "launch:#{user_id}")
      PubSub.subscribe(Leadfoot.PubSub, "session:#{user_id}")
    end

    Session.get_state(user_id)

    {
      :ok,
      assign(socket, @initial_state)
    }
  end

  @impl true
  def handle_info({:update, update}, socket) do
    {:noreply, assign(socket, update)}
  end

  @impl true
  def handle_info({:event, event}, socket) do
    g_force = Float.round(event.acceleration.z, 2)

    {
      :noreply,
      socket
      |> assign(g_force: g_force)
      |> assign(current_race_time: event.current_race_time)
    }
  end
end
