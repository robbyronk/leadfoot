defmodule RaceControl.GearRatios do
  @moduledoc """
  Capture torque,rpm values (as long as gear is > 1 and throttle is 100%)

  Can calculate wheel force for gear,speed
  """

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
  @wheel_diameter 0.632

  use GenServer

  def start_link(state, opts) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(_opts) do
    {:ok, %{}}
  end

  def handle_call(_msg, _from, state) do
    {:reply, :ok, state}
  end

  def handle_cast(_msg, state) do
    {:noreply, state}
  end

  def best_gears() do
    for v <- 1..100 do
      fs =
        for g <- 1..3 do
          {g, v, get_wheel_force_gear_speed(g, v)}
        end

      Enum.max_by(fs, fn {_, _, f} -> f end)
    end
  end

  def get_wheel_rpm(speed), do: speed * 1000 / (60 * :math.pi() * @wheel_diameter)

  def get_engine_rpm(gear, speed), do: get_wheel_rpm(speed) * (@final * Enum.at(@ratios, gear))

  def get_engine_torque(rpm) do
    cond do
      rpm > 8000 -> 0.0
      rpm > 7000 -> 200.0
      rpm > 6000 -> 250.0
      rpm > 4000 -> 290.0
      rpm > 3000 -> 270.0
      rpm > 2000 -> 200.0
      rpm > 1000 -> 150.0
      true -> 0.0
    end
  end

  def get_wheel_force_gear_speed(gear, speed) do
    wheel_radius = @wheel_diameter / 2

    engine_rpm = get_engine_rpm(gear, speed)
    engine_torque = get_engine_torque(engine_rpm)

    wheel_torque =
      get_wheel_torque(Enum.at(@ratios, gear), @final, engine_torque, 2, wheel_radius)

    get_wheel_force(wheel_torque, wheel_radius)
  end

  def get_wheel_force_gear_speed(gear, speed, engine_torques) do
    wheel_radius = @wheel_diameter / 2

    engine_rpm = get_engine_rpm(gear, speed)
    [_rpm, engine_torque] = Enum.find(engine_torques, 0, fn [rpm, t] -> rpm < engine_rpm end)

    get_wheel_torque(
      Enum.at(@ratios, gear),
      @final,
      engine_torque,
      2,
      wheel_radius
    )
    |> get_wheel_force(wheel_radius)
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
