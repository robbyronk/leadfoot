defmodule LeadfootWeb.LapTimeLive.FormComponent do
  @moduledoc false
  use LeadfootWeb, :live_component

  alias Leadfoot.Leaderboard

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage lap_time records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="lap_time-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:lap_time_millis]} type="number" label="Lap time millis" />
        <.input field={@form[:car]} type="text" label="Car" />
        <.input field={@form[:track]} type="text" label="Track" />
        <.input field={@form[:tune]} type="text" label="Tune" />
        <.input field={@form[:input_method]} type="text" label="Input method" />
        <.input field={@form[:video_url]} type="text" label="Video url" />
        <.input field={@form[:notes]} type="text" label="Notes" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Lap time</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{lap_time: lap_time} = assigns, socket) do
    changeset = Leaderboard.change_lap_time(lap_time)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"lap_time" => lap_time_params}, socket) do
    changeset =
      socket.assigns.lap_time
      |> Leaderboard.change_lap_time(lap_time_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"lap_time" => lap_time_params}, socket) do
    save_lap_time(socket, socket.assigns.action, lap_time_params)
  end

  defp save_lap_time(socket, :edit, lap_time_params) do
    case Leaderboard.update_lap_time(socket.assigns.lap_time, lap_time_params) do
      {:ok, lap_time} ->
        notify_parent({:saved, lap_time})

        {:noreply,
         socket
         |> put_flash(:info, "Lap time updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_lap_time(socket, :new, lap_time_params) do
    case Leaderboard.create_lap_time(socket.assigns.current_user, lap_time_params) do
      {:ok, lap_time} ->
        notify_parent({:saved, lap_time})

        {:noreply,
         socket
         |> put_flash(:info, "Lap time created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
