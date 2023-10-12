defmodule LeadfootWeb.LapTimeLive.Index do
  @moduledoc false
  use LeadfootWeb, :live_view

  alias Leadfoot.Accounts
  alias Leadfoot.Leaderboard
  alias Leadfoot.Leaderboard.LapTime

  @impl true
  def mount(_params, session, socket) do
    user =
      case session["user_token"] do
        nil -> nil
        token -> Accounts.get_user_by_session_token(token)
      end

    {:ok,
     socket
     |> assign(current_user: user)
     |> assign(current_user_id: if(user, do: user.id))
     |> stream(:lap_times, Leaderboard.list_lap_times())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    lap_time = Leaderboard.get_lap_time!(id)
    user = socket.assigns.current_user

    if user.id == lap_time.user_id do
      socket
      |> assign(:page_title, "Edit Lap time")
      |> assign(:lap_time, Leaderboard.get_lap_time!(id))
    else
      push_navigate(socket, to: ~p"/lap_times")
    end
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Lap time")
    |> assign(:lap_time, %LapTime{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Lap times")
    |> assign(:lap_time, nil)
  end

  @impl true
  def handle_info({LeadfootWeb.LapTimeLive.FormComponent, {:saved, lap_time}}, socket) do
    {:noreply, stream_insert(socket, :lap_times, lap_time)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    lap_time = Leaderboard.get_lap_time!(id)
    user = socket.assigns.current_user

    if lap_time.user_id == user.id do
      {:ok, _} = Leaderboard.delete_lap_time(lap_time)

      {:noreply, stream_delete(socket, :lap_times, lap_time)}
    else
      {:noreply, socket}
    end
  end
end
