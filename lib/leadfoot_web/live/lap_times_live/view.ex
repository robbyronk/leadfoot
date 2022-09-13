defmodule LeadfootWeb.LapTimesLive.View do
  @moduledoc false

  use LeadfootWeb, :live_view


  @initial_assigns %{
    lap_times: []
  }

  @impl true
  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(Leadfoot.PubSub, "session:lap_times")

    {:ok,
     socket
     |> assign(@initial_assigns)}
  end

  @impl true
  def handle_info(lap_time, socket) do
    {:noreply,
     socket
     |> assign(lap_times: [lap_time | socket.assigns.lap_times])}
  end

  @impl true
  def render(assigns) do
    ~H"""
<h1>lap times</h1>
<%= for l <- @lap_times do %>
  <div><%= l.lap %>: <%= Leadfoot.Translation.to_mm_ss_ms(l.time) %></div>
<% end %>
"""
  end
end
