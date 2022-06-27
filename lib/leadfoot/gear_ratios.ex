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

  @initial_state %{
    gears: @ratios,
    final: @final,
    drive_wheels: 2,
    tire_width: 255,
    tire_ratio: 50,
    wheel_size: 16,
    peak_power: 0,
    peak_torque: 0,
    torques: [],
    recording: false
  }

  use GenServer

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
      %{state | tire_width: width, tire_ratio: ratio, wheel_size: wheel_size}
    }
  end

  def handle_call({:gear_ratios, final, gears}, _from, state) do
    # todo validate
    # todo if a gear is too high or low, push the rest
    {
      :reply,
      :ok,
      %{state | final: final, gears: gears}
    }
  end

  def handle_call(:get_torques, _from, state) do
    {:reply, %{torques: state.torques, recording: state.recording}, state}
  end

  def handle_call(:get_wheel_forces, _from, state) do
    # todo include max power curve
    # P = F*v or put another way: F = P/v
    forces =
      for v <- 1..100 do
        {v, get_wheel_force_gear_speed(1, v, state)}
      end

    {
      :reply,
      forces,
      state
    }
  end

  def handle_cast(:start_recording, state) do
    {:noreply, %{state | recording: true}}
  end

  def handle_cast(:stop_recording, state) do
    {:noreply, %{state | recording: false}}
  end

  def handle_cast(:clear_recording, state) do
    {:noreply, %{state | recording: false, torques: []}}
  end

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
    rpm_is_climbing = event[:current_rpm] > get_most_recent_rpm(state)

    cond do
      event[:current_rpm] < get_most_recent_rpm(state) ->
        %{state | recording: false}

      positive_torque and max_throttle and not_first_gear ->
        %{
          state
          | torques: [{event[:current_rpm], event[:torque]} | state.torques]
        }

      true ->
        state
    end
  end

  def get_wheel_rpm(speed), do: speed * 1000 / (60 * :math.pi() * @wheel_diameter)

  def get_engine_rpm(gear, speed), do: get_wheel_rpm(speed) * (@final * Enum.at(@ratios, gear))

  def get_wheel_force_gear_speed(gear, speed) do
    wheel_radius = @wheel_diameter / 2

    engine_rpm = get_engine_rpm(gear, speed)
    engine_torque = 0

    wheel_torque =
      get_wheel_torque(Enum.at(@ratios, gear), @final, engine_torque, 2, wheel_radius)

    get_wheel_force(wheel_torque, wheel_radius)
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
          2,
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
