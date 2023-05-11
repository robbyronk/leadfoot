defmodule Leadfoot.Tuning.Launch do
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

  use GenServer

  @initial_state %{
    hold_brake_secs: 2,
    recording_secs: 5,
    done_secs: 5,
    done_timer: nil,
    brake_engaged_at: nil,
    brake_released_at: nil,
    status: :stop,
    runs: [],
    current_run: []
  }

  @impl true
  def init(%{user_id: user_id}) do
    PubSub.subscribe(Leadfoot.PubSub, "session:#{user_id}")

    {:ok, @initial_state}
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

  defp transition_to_stop(state) do
    %{state | status: :stop, done_timer: nil}
  end

  defp handle_stop(event, state) do
    if event.speed == 0 do
      transition_to_hold_brake(state)
    else
      state
    end
  end

  defp transition_to_hold_brake(state) do
    %{state | status: :hold_brake, brake_engaged_at: nil}
  end

  defp handle_hold_brake(event, state) do
    cond do
      event.speed > 0 ->
        transition_to_stop(state)

      event.brake == 0 and event.handbrake == 0 ->
        transition_to_hold_brake(state)

      is_nil(state.brake_engaged_at) ->
        %{state | brake_engaged_at: event.current_race_time}

      event.current_race_time > state.brake_engaged_at + state.hold_brake_secs ->
        transition_to_ready_to_launch(state)

      true ->
        state
    end
  end

  defp transition_to_ready_to_launch(state) do
    %{state | status: :ready_to_launch}
  end

  defp handle_ready_to_launch(event, state) do
    cond do
      event.speed > 0 ->
        transition_to_stop(state)

      event.brake == 0 and event.handbrake == 0 ->
        transition_to_recording(event, state)

      true ->
        state
    end
  end

  defp transition_to_recording(event, state) do
    %{state | status: :recording, brake_released_at: event.current_race_time}
  end

  defp capture_event(event, state) do
    %{state | current_run: [event | state.current_run]}
  end

  defp handle_recording(event, state) do
    cond do
      event.current_race_time > state.brake_released_at + state.recording_secs ->
        transition_to_done(state)

      event.current_race_time > state.brake_released_at + 1 and event.speed == 0 ->
        transition_to_stop(state)

      true ->
        capture_event(event, state)
    end
  end

  defp transition_to_done(state) do
    done_timer = Process.send_after(self(), :transition_to_stop, 1000 * state.done_secs)
    runs = [%{events: state.current_run, hide: false} | state.runs]
    %{state | done_timer: done_timer, runs: runs, current_run: [], status: :done}
  end
end
