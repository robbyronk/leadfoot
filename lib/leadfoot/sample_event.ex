defmodule Leadfoot.SampleEvent do
  @moduledoc false

  def sample() do
    %{
      acceleration: %{
        x: 5.429727554321289,
        y: 0.8213579654693604,
        z: 1.2117763757705688
      },
      accelerator: 253,
      ai_brake: 0,
      angular_velocity: %{
        x: -0.00410887598991394,
        y: 0.043515123426914215,
        z: -0.3470175266265869
      },
      best_lap_time: 60.85183334350586,
      boost: 0.0,
      brake: 0,
      car_category: 22,
      car_class: 1,
      car_id: 336,
      car_performance: 600,
      clutch: 0,
      current_lap_time: 57.39279556274414,
      current_race_time: 123.87380981445312,
      current_rpm: 6184.84716796875,
      distance: 11166.416015625,
      drivetrain: 1,
      driving_line: 127,
      fuel: 0.9402942061424255,
      gear: 3,
      handbrake: 0,
      idle_rpm: 1099.9993896484375,
      in_puddle: %{
        front: %{
          left: 0.0,
          right: 0.0
        },
        rear: %{
          left: 0.0,
          right: 0.0
        }
      },
      lap: 1,
      last_lap_time: 60.85183334350586,
      max_rpm: 8999.9951171875,
      num_cylinders: 6,
      on_rumble: %{
        front: %{
          left: 0.0,
          right: 0.0
        },
        rear: %{
          left: 0.0,
          right: 0.0
        }
      },
      position: %{
        x: 937.2786865234375,
        y: 301.0201721191406,
        z: 2768.55419921875
      },
      power: 163_350.796875,
      race_position: 1,
      racing: 1,
      speed: 33.456321716308594,
      steer: 0,
      surface_rumble: %{
        front: %{
          left: 0.0,
          right: 0.0
        },
        rear: %{
          left: 0.0,
          right: 0.0
        }
      },
      suspension_travel: %{
        front: %{
          left: 0.05875369906425476,
          right: -0.026317402720451355
        },
        rear: %{
          left: 0.06553324311971664,
          right: 0.019204825162887573
        }
      },
      timestamp: 4_773_015,
      tire_comb_slip: %{
        front: %{
          left: 0.11383036524057388,
          right: 0.12642832100391388
        },
        rear: %{
          left: 0.23105770349502563,
          right: 0.24594561755657196
        }
      },
      tire_slip_angle: %{
        front: %{
          left: 0.11382265388965607,
          right: 0.12638647854328156
        },
        rear: %{
          left: 0.13807573914527893,
          right: 0.1463562250137329
        }
      },
      tire_slip_ratio: %{
        front: %{
          left: -0.0013248265022411942,
          right: -0.0032527209259569645
        },
        rear: %{
          left: 0.18526402115821838,
          right: 0.19765904545783997
        }
      },
      tire_temp: %{
        front: %{
          left: 144.24893188476562,
          right: 142.46762084960938
        },
        rear: %{
          left: 150.2835235595703,
          right: 150.2835235595703
        }
      },
      torque: 252.14410400390625,
      unknown1: <<0, 0, 0, 0>>,
      unknown2: <<0, 0, 0, 0>>,
      unknown3: <<0>>,
      velocity: %{
        x: -0.4708080291748047,
        y: -0.15454605221748352,
        z: 33.45265197753906
      },
      wheel_rotation: %{
        front: %{
          left: 102.3346939086914,
          right: 102.14707946777344
        },
        rear: %{
          left: 105.00837707519531,
          right: 104.98289489746094
        }
      },
      yaw_pitch_roll: %{
        x: 2.0288658142089844,
        y: -0.11731956154108047,
        z: -0.04284701123833656
      }
    }
  end
end
