defmodule LeadfootWeb.DashboardLive.View do
  @moduledoc false
  use LeadfootWeb, :live_view

  import Leadfoot.SampleEvent
  import Leadfoot.Translation

  alias Leadfoot.Session.Session
  alias Phoenix.PubSub

  @impl true
  def mount(_params, _session, socket) do
    user_id = socket.assigns.current_user.id
    PubSub.subscribe(Leadfoot.PubSub, "session:#{user_id}")
    event = sample()
    %{udp_port: udp_port} = Session.get_state(user_id)

    {
      :ok,
      socket
      |> assign(udp_port: udp_port)
      |> set_assigns(event)
    }
  end

  @impl true
  def handle_info({:event, event}, socket) do
    {
      :noreply,
      set_assigns(socket, event)
    }
  end

  def set_assigns(socket, event) do
    socket
    |> assign(:event, event)
    |> assign(:tach_pct, get_tach_pct(event))
    |> assign(:accel_top, get_accel_top(event))
    |> assign(:accel_left, get_accel_left(event))
  end

  def get_tach_pct(event) do
    max_rpm = event[:max_rpm]
    current_rpm = event[:current_rpm]
    idle_rpm = event[:idle_rpm]

    case max_rpm do
      0.0 -> 0
      _ -> 100 * current_rpm / (max_rpm - idle_rpm)
    end
  end

  def get_accel_top(event) do
    z = event[:acceleration][:z]
    z_g = z / 9.8
    min = 0
    max = 190
    #    min_g = -2
    max_g = 2
    mid = (min + max) / 2
    z_g * mid / max_g + mid
  end

  def get_accel_left(event) do
    x = event[:acceleration][:x]
    x_g = x / 9.8
    min = 0
    max = 190
    #    min_g = -2
    max_g = 2
    mid = (min + max) / 2
    -x_g * mid / max_g + mid
  end
end
