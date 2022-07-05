defmodule Leadfoot.GearRatios do
  @moduledoc """
  Calculates the ideal shift points and the ideal gearing for a car.

  To get ideal shift points:
  1. Set the tire size with set_tire_size/3
  2. Set the gear ratios with set_gears/2
  3. Record a "dyno pull" with start_recording/0
  4. Get the shift points with get_shift_points/0

  To record a "dyno pull":
  1. Get your car to a long straight with no obstacles.
  2. Start recording with start_recording/1
  3. Get your car rolling with 50% power.
  4. Shift into 2nd gear and keep accelerating with 50% power until your engine is at 2000-3000 RPM.
  5. Full power.
  6. Full power all the way until you hit the rev limiter.

  To get the ideal gearing:
  1. Find a first gear that launches nicely. Input the final and first gear ratios.
  2. Enter target top speed.
  Look at chart with speed on x axis, force on y axis.
  The min speed shown is at the peak torque in 1st gear.
  The max speed shown is the target top speed.
  The plotted values are ideal_max_force - max_gear_force, for each speed.
  Adjust gear ratios to minimize the plotted values.


  Sample inputs:

  Subaru 22B:
  final: 3.85
  4.14 2.67 1.82 1.33 1.0 0.8
  235/40R17 235/40R17

  Twerkstallion 4 Rotor:
  final: 3.05
  4.17 3.01 2.38 1.96 1.64 1.41 1.25 1.14
  225/40R18 295/30R18
  """

  alias Phoenix.PubSub
  alias Leadfoot.CarSettings.Tires
  alias Leadfoot.CarSettings.Gearbox

  # rx7 stock tires: 225/50R16
  # 22b stock tires: 235/40R17

  @initial_state %{
    tires: %Tires{width: 235, ratio: 40, size: 17},
    gearbox: %Gearbox{final: 3.85, gear1: 4.14, gear2: 2.67, gear3: 1.82, gear4: 1.33, gear5: 1.0, gear6: 0.8},
    drive_wheels: 4,
    peak_power: 0,
    peak_torque: 0,
    torques: [],
    forces: [],
    power_multiple: 1,
    recording: true
  }

  @server Leadfoot.GearRatios

  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: @server)
  end

  def start_link(state, opts) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  @impl true
  def init(_opts) do
    PubSub.subscribe(Leadfoot.PubSub, "session")

    {:ok, @initial_state}
  end

  def get_tires(), do: GenServer.call(@server, :get_tires)

  def set_tire_size(%Tires{} = tires), do: GenServer.cast(@server, {:tire_size, tires})

  def get_gearbox(), do: GenServer.call(@server, :get_gearbox)

  def set_gearbox(%Gearbox{} = gearbox), do: GenServer.cast(@server, {:gearbox, gearbox})

  def get_torques(), do: GenServer.call(@server, :get_torques)

  def get_wheel_forces(), do: GenServer.call(@server, :get_wheel_forces)

  def get_shift_points(), do: GenServer.call(@server, :get_shift_points)

  def start_recording(), do: GenServer.cast(@server, :start_recording)

  def stop_recording(), do: GenServer.cast(@server, :stop_recording)

  def clear_recording(), do: GenServer.cast(@server, :clear_recording)

  @impl true
  def handle_info({:event, event}, state) do
    case state.recording do
      false -> {:noreply, state}
      true -> {:noreply, capture_torque(event, state)}
    end
  end

  @impl true
  def handle_call(:get_tires, _from, state), do: {:reply, state.tires, state}

  @impl true
  def handle_call(:get_gearbox, _from, state), do: {:reply, state.gearbox, state}

  @impl true
  def handle_call(:get_torques, _from, state) do
    {:reply, %{torques: state.torques, recording: state.recording}, state}
  end

  @impl true
  def handle_call(:get_shift_points, _from, state) do
    state = calculate_forces(state)

    {
      :reply,
      calculate_shift_points(state),
      state
    }
  end

  @impl true
  def handle_call(:get_wheel_forces, _from, state) do
    state = calculate_forces(state)

    # todo accumulate force and max power curve in one loop
    forces =
      for {_gear, _rpm, velocity, force} <- state.forces do
        {velocity, force}
      end

    power = state.peak_power * state.power_multiple

    power_curve =
      for {_gear, _rpm, velocity, _force} <- state.forces, power / velocity < 30000 do
        {velocity, power / velocity}
      end

    {
      :reply,
      forces ++ power_curve,
      state
    }
  end

  @impl true
  def handle_cast({:gearbox, gearbox}, state) do
    { :noreply, %{state | gearbox: gearbox, forces: []} }
  end

  @impl true
  def handle_cast({:tire_size, tires}, state) do
    {:noreply, %{state | tires: tires, forces: []}}
  end

  @impl true
  def handle_cast(:start_recording, state) do
    {:noreply, %{state | recording: true, torques: [], forces: []}}
  end

  @impl true
  def handle_cast(:stop_recording, state) do
    {:noreply, %{state | recording: false}}
  end

  @impl true
  def handle_cast(:clear_recording, state) do
    {:noreply, %{state | recording: false, torques: [], forces: []}}
  end

  @impl true
  def handle_cast({:set_power_multiple, power_multiple}, state) do
    {:noreply, %{state | power_multiple: power_multiple}}
  end

  def calculate_shift_points(state) do
    wheel_diameter = Tires.get_tire_height(state.tires)
    wheel_radius = wheel_diameter / 2

    # todo use precalculated forces

    gears = Gearbox.get_gears(state.gearbox) |> Enum.with_index()
    final = state.gearbox.final

    a =
      for {gear_ratio, gear_index} <- gears do
        x =
          for {rpm, torque} <- state.torques do
            {
              gear_index + 1,
              rpm,
              get_velocity(final, gear_ratio, rpm, wheel_diameter),
              get_wheel_force(gear_ratio, final, torque, state.drive_wheels, wheel_radius)
            }
          end

        Enum.sort_by(x, fn {_, _, v, _} -> v end)
      end

    calculate_shift_point(a)
  end

  def calculate_shift_point([_last_gear]), do: []

  def calculate_shift_point([current_gear, next_gear | rest_gears]) do
    {c, next_gear} = find_next_shift_point(current_gear, next_gear)

    [c | calculate_shift_point([next_gear | rest_gears])]
  end

  def find_next_shift_point([], []), do: {nil, []}

  def find_next_shift_point([c | current_gear_forces], [n1, n2 | next_gear_forces]) do
    # find last current gear tuple c where c.force < n2.force,
    # where n1.speed < c.speed <= n2.speed
    {_c_gear, _c_rpm, c_v, c_f} = c
    {_n1_gear, _n1_rpm, n1_v, _n1_f} = n1
    {_n2_gear, _n2_rpm, n2_v, n2_f} = n2

    cond do
      length(current_gear_forces) == 0 ->
        {c, next_gear_forces}

      n1_v < c_v and c_v <= n2_v and c_f <= n2_f ->
        {c, next_gear_forces}

      n1_v < c_v and c_v <= n2_v and c_f > n2_f ->
        find_next_shift_point(current_gear_forces, [n1, n2 | next_gear_forces])

      n1_v >= c_v ->
        find_next_shift_point(current_gear_forces, [n1, n2 | next_gear_forces])

      c_v > n2_v ->
        find_next_shift_point([c | current_gear_forces], [n2 | next_gear_forces])

      true ->
        {nil, next_gear_forces}
    end
  end

  def calculate_forces(%{forces: []} = state) do
    wheel_diameter = Tires.get_tire_height(state.tires)
    wheel_radius = wheel_diameter / 2

    gears = Gearbox.get_gears(state.gearbox) |> Enum.with_index()
    final = state.gearbox.final

    forces =
      for {rpm, torque} <- state.torques, {gear_ratio, gear_index} <- gears do
        {
          gear_index + 1,
          rpm,
          get_velocity(final, gear_ratio, rpm, wheel_diameter),
          get_wheel_force(gear_ratio, final, torque, state.drive_wheels, wheel_radius)
        }
      end

    %{state | forces: forces}
  end

  def calculate_forces(state), do: state

  def get_most_recent_rpm(state) do
    case state.torques do
      [] -> 0
      [{rpm, _torque} | _rest] -> rpm
    end
  end

  def capture_torque(event, state) do
    positive_torque = event[:torque] > 0
    max_throttle = event[:accelerator] > 250
    not_first_gear = event[:gear] > 1
    peak_power = max(event[:power], state.peak_power)
    peak_torque = max(event[:torque], state.peak_torque)
    drive_wheels = if event[:drivetrain] == 2, do: 4, else: 2

    cond do
      event[:current_rpm] < get_most_recent_rpm(state) ->
        %{state | recording: false}

      positive_torque and max_throttle and not_first_gear ->
        %{
          state
          | torques: [{event[:current_rpm], event[:torque]} | state.torques],
            peak_power: peak_power,
            peak_torque: peak_torque,
            drive_wheels: drive_wheels
        }

      true ->
        state
    end
  end

  @doc """
  Calculates the velocity of the car in kph

      iex> Float.round(Leadfoot.GearRatios.get_velocity(4.0, 1.0, 5000, 0.6), 2)
      141.37

      iex> Float.round(Leadfoot.GearRatios.get_velocity(4.0, 2.0, 5000, 0.6), 2)
      70.69
  """
  def get_velocity(final, gear, engine_rpm, wheel_diameter) do
    wheel_rpm = engine_rpm / (final * gear)
    wheel_rpm * 60 * :math.pi() * wheel_diameter / 1000
  end

  def get_wheel_force(gear_ratio, final_ratio, engine_torque, total_drive_wheels, wheel_radius) do
    gear_ratio * final_ratio * engine_torque / (total_drive_wheels * wheel_radius)
  end
end
