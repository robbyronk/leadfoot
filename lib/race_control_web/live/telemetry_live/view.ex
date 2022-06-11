defmodule RaceControlWeb.TelemetryLive.View do
  @moduledoc false
  use RaceControlWeb, :live_view
  alias Phoenix.PubSub

  @impl true
  def mount(_params, session, socket) do
    #    file = RaceControl.ReadFile.read("session.forza")
    PubSub.subscribe(RaceControl.PubSub, "session")
    event = sample()

    {
      :ok,
      socket
      |> assign(:event, event)
      |> assign(:tach_pct, get_tach_pct(event))
      |> assign(:accel_top, get_accel_top(event))
      |> assign(:accel_left, get_accel_left(event))
    }
  end

  def handle_info({:event, event}, socket) do
    {
      :noreply,
      socket
      |> assign(:event, event)
      |> assign(:tach_pct, get_tach_pct(event))
      |> assign(:accel_top, get_accel_top(event))
      |> assign(:accel_left, get_accel_left(event))
    }
  end

  def get_tach_pct(event) do
    max_rpm = event[:max_rpm]
    current_rpm = event[:current_rpm]
    idle_rpm = event[:idle_rpm]

    case max_rpm do
      0.0 -> 0
      _ -> 100 * current_rpm / (max_rpm - idle_rpm)
    end
  end

  def get_accel_top(event) do
    z = event[:acceleration][:z]
    z_g = z / 9.8
    min = 0
    max = 190
    min_g = -2
    max_g = 2
    mid = (min + max) / 2
    z_g * mid / max_g + mid
  end

  def get_accel_left(event) do
    x = event[:acceleration][:x]
    x_g = x / 9.8
    min = 0
    max = 190
    min_g = -2
    max_g = 2
    mid = (min + max) / 2
    -x_g * mid / max_g + mid
  end

  def sample() do
    %{
      racing: 1,
      idle_rpm: 1099.9993896484375,
      current_race_time: 123.87380981445312,
      handbrake: 0,
      boost: 0.0,
      speed: 33.456321716308594,
      suspension_travel: %{
        front: %{left: 0.05875369906425476, right: -0.026317402720451355},
        rear: %{left: 0.06553324311971664, right: 0.019204825162887573}
      },
      distance: 11166.416015625,
      in_puddle: %{front: %{left: 0.0, right: 0.0}, rear: %{left: 0.0, right: 0.0}},
      tire_slip_ratio: %{
        front: %{left: -0.0013248265022411942, right: -0.0032527209259569645},
        rear: %{left: 0.18526402115821838, right: 0.19765904545783997}
      },
      velocity: %{
        x: -0.4708080291748047,
        y: -0.15454605221748352,
        z: 33.45265197753906
      },
      car_id: 336,
      car_performance: 600,
      gear: 3,
      best_lap_time: 60.85183334350586,
      car_category: 22,
      driving_line: 127,
      tire_temp: %{
        front: %{left: 144.24893188476562, right: 142.46762084960938},
        rear: %{left: 150.2835235595703, right: 150.2835235595703}
      },
      current_lap_time: 57.39279556274414,
      accelerator: 253,
      unknown1: <<0, 0, 0, 0>>,
      tire_slip_angle: %{
        front: %{left: 0.11382265388965607, right: 0.12638647854328156},
        rear: %{left: 0.13807573914527893, right: 0.1463562250137329}
      },
      brake: 0,
      car_class: 1,
      num_cylinders: 6,
      wheel_rotation: %{
        front: %{left: 102.3346939086914, right: 102.14707946777344},
        rear: %{left: 105.00837707519531, right: 104.98289489746094}
      },
      torque: 252.14410400390625,
      yaw_pitch_roll: %{
        x: 2.0288658142089844,
        y: -0.11731956154108047,
        z: -0.04284701123833656
      },
      unknown2: <<0, 0, 0, 0>>,
      drivetrain: 1,
      tire_comb_slip: %{
        front: %{left: 0.11383036524057388, right: 0.12642832100391388},
        rear: %{left: 0.23105770349502563, right: 0.24594561755657196}
      },
      on_rumble: %{front: %{left: 0.0, right: 0.0}, rear: %{left: 0.0, right: 0.0}},
      race_position: 1,
      steer: 0,
      current_rpm: 6184.84716796875,
      position: %{x: 937.2786865234375, y: 301.0201721191406, z: 2768.55419921875},
      ai_brake: 0,
      acceleration: %{
        x: 5.429727554321289,
        y: 0.8213579654693604,
        z: 1.2117763757705688
      },
      max_rpm: 8999.9951171875,
      surface_rumble: %{
        front: %{left: 0.0, right: 0.0},
        rear: %{left: 0.0, right: 0.0}
      },
      clutch: 0,
      last_lap_time: 60.85183334350586,
      angular_velocity: %{
        x: -0.00410887598991394,
        y: 0.043515123426914215,
        z: -0.3470175266265869
      },
      timestamp: 4_773_015,
      lap: 1,
      power: 163_350.796875,
      fuel: 0.9402942061424255,
      unknown3: <<0>>
    }
  end
end
