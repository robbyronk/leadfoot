defmodule LeadfootWeb.SuspensionCalculatorLive.View do
  @moduledoc false
  use LeadfootWeb, :live_view

  alias Leadfoot.Suspension.Calculator

  @initial_assigns %{
    values: %Calculator{
      front_downforce: 0.0,
      rear_downforce: 0.0
    },
    front_frequency: 0.0,
    rear_frequency: 0.0,
    ratio: 0.0,
    front_with_downforce: 0.0,
    rear_with_downforce: 0.0,
    ratio_with_downforce: 0.0,
    changeset: nil,
    form: nil
  }

  @impl true
  def mount(_params, _session, socket) do
    {
      :ok,
      socket
      |> assign(@initial_assigns)
      |> assign_changeset()
    }
  end

  def assign_changeset(socket) do
    changeset = Calculator.changeset(socket.assigns.values, %{})

    socket
    |> assign(changeset: changeset)
    |> assign(form: to_form(changeset))
  end

  @impl true
  def handle_event("validate", params, socket) do
    changeset =
      socket.assigns.values
      |> Calculator.changeset(params["calculator"])
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event("save", params, socket) do
    IO.inspect(params)

    changeset = Calculator.changeset(socket.assigns.values, params["calculator"])

    if changeset.valid? do
      {:ok, new_values} = Ecto.Changeset.apply_action(changeset, :update)

      {front, rear, front_with_downforce, rear_with_downforce} = Calculator.get_frequencies(new_values)

      ratio = rear / front
      ratio_with_downforce = rear_with_downforce / front_with_downforce

      {
        :noreply,
        socket
        |> assign(values: new_values, front_frequency: front, rear_frequency: rear)
        |> assign(ratio: ratio, ratio_with_downforce: ratio_with_downforce)
        |> assign(
          front_with_downforce: front_with_downforce,
          rear_with_downforce: rear_with_downforce
        )
        |> assign_changeset()
      }
    else
      {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
