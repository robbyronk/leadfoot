defmodule Leadfoot.GearRatios do
  @moduledoc """
  Capture torque,rpm values (as long as gear is > 1 and throttle is 100%)

  Can calculate wheel force for gear,speed.

  1. Get wheel height and gear ratios.
  2. Capture torque curve.

  Calls:
  - Set wheel height, gear ratios.
  - Get torque curve
  - Get wheel force curves

  Casts:
  - Start recording torque curve
  - Stop recording torque curve
  - Clear torque data


  22b gears:
  final: 3.85
  4.14 2.67 1.82 1.33 1.0 0.8

  4 rotor:
  final: 3.05
  4.17 3.01 2.38 1.96 1.64 1.41 1.25 1.14
  225/40R18 295/30R18
  """

  alias Phoenix.PubSub

  # need to know what the torque will be in any gear at any speed
  # https://x-engineer.org/calculate-wheel-torque-engine/

  # need torque curve to know what torque will be at rpm
  # need fn to know what rpm in what gear at speed
  # fn to find highest torque gear for speed

  @final 3.67

  # 1 indexed, like a gear selection. Matches event data
  @ratios [
    0.0,
    3.54,
    2.56,
    1.82,
    1.34,
    1.03,
    0.84
  ]

  # rx7 stock tires: 225/50R16
  # 22b stock tires: 235/40R17
  @wheel_diameter 0.632

  # todo capture drive wheels, peak torque
  @initial_state %{
    ratios: @ratios,
    final: @final,
    drive_wheels: 4,
    tire_width: 235,
    tire_ratio: 40,
    wheel_size: 17,
    peak_power: 0,
    peak_torque: 0,
    torques: [],
    forces: [],
  power_multiple: 10,
    recording: true
  }

  use GenServer

  def scratch() do
    GearRatios.set_gears(3.85, [4.14, 2.67, 1.82, 1.33, 1.0, 0.8])
  end

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: Leadfoot.GearRatios)
  end

  def start_link(state, opts) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(_opts) do
    PubSub.subscribe(Leadfoot.PubSub, "session")

    {:ok, @initial_state}
  end

  def set_tire_size(width, ratio, wheel_size) do
    GenServer.call(Leadfoot.GearRatios, {:tire_size, width, ratio, wheel_size})
  end

  def set_gears(final, gears) do
    GenServer.call(Leadfoot.GearRatios, {:gear_ratios, final, [0 | gears]})
  end

  def get_torques(), do: GenServer.call(Leadfoot.GearRatios, :get_torques)

  def get_wheel_forces(), do: GenServer.call(Leadfoot.GearRatios, :get_wheel_forces)

  def get_shift_points(), do: GenServer.call(Leadfoot.GearRatios, :get_shift_points)

  def start_recording(), do: GenServer.cast(Leadfoot.GearRatios, :start_recording)

  def stop_recording(), do: GenServer.cast(Leadfoot.GearRatios, :stop_recording)

  def clear_recording(), do: GenServer.cast(Leadfoot.GearRatios, :clear_recording)

  def handle_info({:event, event}, state) do
    case state.recording do
      false -> {:noreply, state}
      true -> {:noreply, capture_torque(event, state)}
    end
  end

  def handle_call({:tire_size, width, ratio, wheel_size}, _from, state) do
    # todo validate
    {
      :reply,
      {:ok, get_tire_height(width, ratio, wheel_size)},
      %{state | tire_width: width, tire_ratio: ratio, wheel_size: wheel_size, forces: []}
    }
  end

  def handle_call({:gear_ratios, final, gears}, _from, state) do
    # todo validate
    # todo if a gear is too high or low, push the rest
    {
      :reply,
      :ok,
      %{state | final: final, ratios: gears, forces: []}
    }
  end

  def handle_call(:get_torques, _from, state) do
    {:reply, %{torques: state.torques, recording: state.recording}, state}
  end

  def handle_call(:get_shift_points, _from, state) do
    state = calculate_forces(state)

    {
      :reply,
      calculate_shift_points(state),
      state
    }
  end

  def handle_call(:get_wheel_forces, _from, state) do
    # todo include max power curve
    # P = F*v or put another way: F = P/v

    state = calculate_forces(state)

    power = state.peak_power * state.power_multiple

    forces =
      for {_gear, _rpm, velocity, force} <- state.forces do
        {velocity, force}
      end

    power_curve =
      for {_gear, _rpm, velocity, force} <- state.forces, (power / velocity) < 30000 do
        {velocity, power / velocity}
      end

    {
      :reply,
      forces ++ power_curve,
      state
    }
  end

  def handle_cast(:start_recording, state) do
    {:noreply, %{state | recording: true}}
  end

  def handle_cast(:stop_recording, state) do
    {:noreply, %{state | recording: false}}
  end

  def handle_cast({:set_power_multiple, power_multiple}, state) do
    {:noreply, %{state | power_multiple: power_multiple}}
  end

  def handle_cast(:clear_recording, state) do
    {:noreply, %{state | recording: false, torques: [], forces: []}}
  end

  def calculate_shift_points(state) do
    wheel_radius = get_tire_height(state.tire_width, state.tire_ratio, state.wheel_size) / 2

    # todo use precalculated forces

    gears_count = length(state.ratios) - 1

    a =
      for gear <- 1..gears_count do
        x =
          for {rpm, torque} <- state.torques do
            {
              gear,
              rpm,
              get_velocity(state.final, Enum.at(state.ratios, gear), rpm, wheel_radius),
              get_force(torque, gear, rpm, wheel_radius, state)
            }
          end

        Enum.sort_by(x, fn {_, _, v, _} -> v end)
      end

    calculate_shift_point(a)
  end

  def calculate_shift_point([last_gear]) do
    []
  end

  def calculate_shift_point([current_gear, next_gear | rest_gears] = gears_speed_forces) do
    {c, next_gear} = find_next_shift_point(current_gear, next_gear)

    [c | calculate_shift_point([next_gear | rest_gears])]
  end

  def find_next_shift_point([], []) do
    {nil, []}
  end

  def find_next_shift_point([c | current_gear_forces], [n1, n2 | next_gear_forces]) do
    # find last current gear tuple c where c.force < n2.force,
    # where n1.speed < c.speed <= n2.speed
    {c_gear, c_rpm, c_v, c_f} = c
    {n1_gear, n1_rpm, n1_v, n1_f} = n1
    {n2_gear, n2_rpm, n2_v, n2_f} = n2

    cond do
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
    wheel_radius = get_tire_height(state.tire_width, state.tire_ratio, state.wheel_size) / 2

    gears_count = length(state.ratios) - 1
    forces =
      for {rpm, torque} <- state.torques, gear <- 1..gears_count do
        {
          gear,
          rpm,
          get_velocity(state.final, Enum.at(state.ratios, gear), rpm, wheel_radius),
          get_force(torque, gear, rpm, wheel_radius, state)
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

    cond do
      event[:current_rpm] < get_most_recent_rpm(state) ->
        %{state | recording: false}

      positive_torque and max_throttle and not_first_gear ->
        %{
          state
          | torques: [{event[:current_rpm], event[:torque]} | state.torques],
        peak_power: peak_power

        }

      true ->
        state
    end
  end

  def get_wheel_rpm(speed), do: speed * 1000 / (60 * :math.pi() * @wheel_diameter)

  def get_engine_rpm(gear, speed), do: get_wheel_rpm(speed) * (@final * Enum.at(@ratios, gear))

  def get_velocity(final, gear, engine_rpm, wheel_radius) do
    wheel_rpm = engine_rpm / (final * gear)
    wheel_rpm * 60 * :math.pi() * wheel_radius * 2 / 1000
  end

  def get_wheel_force_gear_speed(gear, speed) do
    wheel_radius = @wheel_diameter / 2

    engine_rpm = get_engine_rpm(gear, speed)
    engine_torque = 0

    wheel_torque =
      get_wheel_torque(Enum.at(@ratios, gear), @final, engine_torque, 4, wheel_radius)

    get_wheel_force(wheel_torque, wheel_radius)
  end

  def get_force(engine_torque, gear, engine_rpm, wheel_radius, state) do
    get_wheel_torque(
      Enum.at(state.ratios, gear),
      state.final,
      engine_torque,
      state.drive_wheels,
      wheel_radius
    )
    |> get_wheel_force(wheel_radius)
  end

  def get_wheel_force_gear_speed(gear, speed, %{torques: []}), do: 0

  def get_wheel_force_gear_speed(gear, speed, state) do
    wheel_radius = @wheel_diameter / 2
    engine_torques = state.torques

    engine_rpm = get_engine_rpm(gear, speed)
    # todo this is blowing up when it cant find a torque
    case Enum.find(engine_torques, 0, fn {rpm, t} -> rpm < engine_rpm end) do
      0 ->
        0

      {_rpm, engine_torque} ->
        get_wheel_torque(
          Enum.at(@ratios, gear),
          @final,
          engine_torque,
          4,
          wheel_radius
        )
        |> get_wheel_force(wheel_radius)
    end
  end

  def get_wheel_torque(gear_ratio, final_ratio, engine_torque, total_drive_wheels, wheel_radius) do
    gear_ratio * final_ratio * engine_torque / (total_drive_wheels * wheel_radius)
  end

  def get_wheel_force(wheel_torque, wheel_radius) do
    wheel_torque / wheel_radius
  end

  def get_tire_height(width, aspect_ratio, wheel_size) do
    # width is in mm
    # aspect ratio is a whole number, like 50 or 65
    # wheel size is in inches
    wheel_size * 0.0254 + width * (aspect_ratio / 100) * 2 / 1000
  end

  def rad_per_sec_to_rpm(rads), do: rads * 9.549297

  def get_fastest_drive_wheel(event) do
    case event[:drivetrain] do
      0 -> get_fastest_wheel(event, :front)
      1 -> get_fastest_wheel(event, :rear)
      _ -> max(get_fastest_wheel(event, :front), get_fastest_wheel(event, :rear))
    end
  end

  def get_fastest_wheel(event, front_rear) do
    # wheel rotation is in rad/sec
    left = event[:wheel_rotation][front_rear][:left]
    right = event[:wheel_rotation][front_rear][:right]
    max(left, right)
  end
end
