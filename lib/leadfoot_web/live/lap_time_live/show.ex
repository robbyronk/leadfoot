defmodule LeadfootWeb.LapTimeLive.Show do
  @moduledoc false
  use LeadfootWeb, :live_view

  alias Leadfoot.Leaderboard

  @impl true
  def mount(%{"id" => id}, session, socket) do
    user = Accounts.get_user_by_session_token(session["user_token"])
    lap_time = Leaderboard.get_lap_time!(id)

    {:ok, assign(socket, current_user: user)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    lap_time = Leaderboard.get_lap_time!(id)
    user = socket.assigns.current_user

    if user.id == lap_time.user_id do
      {:noreply,
       socket
       |> assign(:page_title, page_title(socket.assigns.live_action))
       |> assign(:lap_time, lap_time)}
    else
      {:noreply, push_navigate(socket, to: ~p"/lap_times")}
    end
  end

  defp page_title(:show), do: "Show Lap time"
  defp page_title(:edit), do: "Edit Lap time"
end
