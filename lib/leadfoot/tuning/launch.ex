defmodule Leadfoot.Tuning.Launch do
  @moduledoc false
  use GenServer

  alias Phoenix.PubSub

  @doc """
  GenServer to collect and hold data for tuning the launch of the car.

  There are 5 main states of the collector:
    - Stop
    - Hold Brake
    - Ready to Launch
    - Recording
    - Done

  To transition out of the Stop state, the car needs to stop. Once stopped, we transition to the Hold Brake state.
    
  When in the Hold Brake state, if the car starts moving, we transition to the Stop state. To transition out of
  the Hold Brake state, the brake or handbrake needs to be held for 2 seconds. If the brake/handbrake is released
  transition back to Stop. Otherwise we transition to Ready to Launch.

  When in the Ready to Launch state, if the car starts moving, we transition to the Stop state. Releasing the 
  brake/handbrake transitions to Recording.
    
  When in Recording, if the speed returns to zero after 1 second, transition to Stop. Normally, after 5 seconds,
  transition to Done.

  When in Done, transition to Stop after 5 seconds.
  """

  @initial_state %{
    hold_brake_secs: 2,
    recording_secs: 5,
    done_secs: 5,
    done_timer: nil,
    brake_engaged_at: nil,
    brake_released_at: nil,
    status: :stop,
    runs: [],
    current_run: [],
    user_id: nil
  }

  def start_link(initial) do
    GenServer.start_link(__MODULE__, initial)
  end

  @impl true
  def init(%{user_id: user_id}) do
    PubSub.subscribe(Leadfoot.PubSub, "session:#{user_id}")
    state = Map.put(@initial_state, :user_id, user_id)
    broadcast(state)

    {:ok, state}
  end

  def get_state(pid) do
    GenServer.call(pid, :get_state)
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_info(:transition_to_stop, state) do
    {:noreply, transition_to_stop(state)}
  end

  @impl true
  def handle_info({:event, event}, state) do
    state =
      case state.status do
        :stop -> handle_stop(event, state)
        :hold_brake -> handle_hold_brake(event, state)
        :ready_to_launch -> handle_ready_to_launch(event, state)
        :recording -> handle_recording(event, state)
        :done -> state
      end

    {:noreply, state}
  end

  defp broadcast(%{user_id: user_id, status: status, runs: runs} = state) do
    PubSub.broadcast(
      Leadfoot.PubSub,
      "launch:#{user_id}",
      {:update, %{status: status, runs: runs}}
    )

    state
  end

  defp is_moving?(event) do
    event.speed > 0.1
  end

  defp transition_to_stop(state, event \\ nil) do
    broadcast(%{state | status: :stop, done_timer: nil, current_run: []})
  end

  defp handle_stop(event, state) do
    if is_moving?(event) do
      state
    else
      transition_to_hold_brake(state)
    end
  end

  defp transition_to_hold_brake(state) do
    broadcast(%{state | status: :hold_brake, brake_engaged_at: nil})
  end

  defp brake_engaged(event, state) do
    %{state | brake_engaged_at: event.current_race_time}
  end

  defp handle_hold_brake(event, state) do
    cond do
      is_moving?(event) ->
        transition_to_stop(state, event)

      event.brake == 0 and event.handbrake == 0 ->
        transition_to_hold_brake(state)

      is_nil(state.brake_engaged_at) ->
        brake_engaged(event, state)

      event.current_race_time > state.brake_engaged_at + state.hold_brake_secs ->
        transition_to_ready_to_launch(state)

      true ->
        state
    end
  end

  defp transition_to_ready_to_launch(state) do
    broadcast(%{state | status: :ready_to_launch})
  end

  defp handle_ready_to_launch(event, state) do
    cond do
      is_moving?(event) ->
        transition_to_stop(state, event)

      event.brake == 0 and event.handbrake == 0 ->
        transition_to_recording(event, state)

      true ->
        state
    end
  end

  defp transition_to_recording(event, state) do
    broadcast(%{state | status: :recording, brake_released_at: event.current_race_time})
  end

  defp capture_event(event, state) do
    %{state | current_run: [event | state.current_run]}
  end

  defp handle_recording(event, state) do
    cond do
      event.current_race_time > state.brake_released_at + state.recording_secs ->
        transition_to_done(state)

      event.current_race_time > state.brake_released_at + 1 and not is_moving?(event) ->
        transition_to_stop(state, event)

      true ->
        capture_event(event, state)
    end
  end

  defp transition_to_done(state) do
    done_timer = Process.send_after(self(), :transition_to_stop, 1000 * state.done_secs)
    peak_g = state.current_run |> Enum.map(fn e -> e.acceleration.z end) |> Enum.max()
    runs = [%{peak_g: peak_g, hide: false} | state.runs]
    broadcast(%{state | done_timer: done_timer, runs: runs, current_run: [], status: :done})
  end
end
