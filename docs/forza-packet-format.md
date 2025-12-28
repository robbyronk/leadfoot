# Forza Horizon 5 Binary Packet Format

This document describes the binary UDP telemetry packet format used by Forza Horizon 5's "Data Out" feature.

## Overview

Forza Horizon 5 can stream real-time telemetry data over UDP at approximately 60Hz. The data is sent as binary packets in little-endian byte order.

### Enabling Telemetry Output

1. Open Forza Horizon 5 Settings
2. Navigate to **HUD and Gameplay**
3. Scroll down to **Data Out**
4. Set **Data Out** to "On"
5. Enter your destination **IP Address** (e.g., your PC's IP)
6. Set the **Data Out Port** (default: 21337)

## Packet Structure

The telemetry packet is 323+ bytes and contains all data in **little-endian** format.

### Data Types

| Type | Size | Description |
|------|------|-------------|
| `s32` | 4 bytes | Signed 32-bit integer |
| `u32` | 4 bytes | Unsigned 32-bit integer |
| `f32` | 4 bytes | 32-bit IEEE 754 floating point |
| `s16` | 2 bytes | Signed 16-bit integer |
| `u16` | 2 bytes | Unsigned 16-bit integer |
| `s8` | 1 byte | Signed 8-bit integer |
| `u8` | 1 byte | Unsigned 8-bit integer |

### Compound Types

**Vector3 (12 bytes)**
```
{ x: f32, y: f32, z: f32 }
```

**Corners (16 bytes)** - Values for each wheel
```
{ front_left: f32, front_right: f32, rear_left: f32, rear_right: f32 }
```

## Field Layout

| Offset | Size | Type | Field | Description |
|--------|------|------|-------|-------------|
| 0 | 4 | s32 | `racing` | Race state (0 = not racing, 1 = racing) |
| 4 | 4 | u32 | `timestamp` | Game timestamp, increments at ~60Hz |
| 8 | 4 | f32 | `max_rpm` | Engine maximum RPM (redline/fuel cutoff) |
| 12 | 4 | f32 | `idle_rpm` | Engine idle RPM |
| 16 | 4 | f32 | `current_rpm` | Current engine RPM |
| 20 | 12 | Vector3 | `acceleration` | Acceleration in m/s² (X, Y, Z) |
| 32 | 12 | Vector3 | `velocity` | Velocity in m/s (X, Y, Z) |
| 44 | 12 | Vector3 | `angular_velocity` | Angular velocity in rad/s |
| 56 | 12 | Vector3 | `yaw_pitch_roll` | Orientation in radians |
| 68 | 16 | Corners | `norm_suspension` | Normalized suspension travel (0.0 - 1.0) |
| 84 | 16 | Corners | `tire_slip_ratio` | Tire slip ratio |
| 100 | 16 | Corners | `wheel_rotation` | Wheel rotation speed in rad/s |
| 116 | 16 | Corners | `on_rumble` | Wheel on rumble strip |
| 132 | 16 | Corners | `in_puddle` | Wheel in puddle depth |
| 148 | 16 | Corners | `surface_rumble` | Surface rumble intensity |
| 164 | 16 | Corners | `tire_slip_angle` | Tire slip angle |
| 180 | 16 | Corners | `tire_comb_slip` | Combined tire slip |
| 196 | 16 | Corners | `suspension_travel` | Suspension travel in meters |
| 212 | 4 | s32 | `car_id` | Unique car ordinal/identifier |
| 216 | 4 | s32 | `car_class` | Car class index (see enum below) |
| 220 | 4 | s32 | `car_performance` | Performance Index (PI) rating |
| 224 | 4 | s32 | `drivetrain` | Drivetrain type (see enum below) |
| 228 | 4 | s32 | `num_cylinders` | Number of engine cylinders |
| 232 | 4 | s32 | `car_category` | Car category index (see enum below) |
| 236 | 4 | - | `unknown1` | Unknown (changes during collisions) |
| 240 | 4 | - | `unknown2` | Unknown (changes during collisions) |
| 244 | 12 | Vector3 | `world_position` | World position in meters (X, Y, Z) |
| 256 | 4 | f32 | `speed` | Speed in m/s |
| 260 | 4 | f32 | `power` | Current engine power in watts |
| 264 | 4 | f32 | `torque` | Current engine torque in N·m |
| 268 | 16 | Corners | `tire_temp` | Tire temperature in Fahrenheit |
| 284 | 4 | f32 | `boost` | Turbo/supercharger boost pressure |
| 288 | 4 | f32 | `fuel` | Fuel level (0.0 - 1.0) |
| 292 | 4 | f32 | `distance` | Distance traveled in meters |
| 296 | 4 | f32 | `best_lap_time` | Best lap time in seconds |
| 300 | 4 | f32 | `last_lap_time` | Last lap time in seconds |
| 304 | 4 | f32 | `current_lap_time` | Current lap time in seconds |
| 308 | 4 | f32 | `current_race_time` | Total race time in seconds |
| 312 | 2 | u16 | `lap` | Current lap number |
| 314 | 1 | u8 | `race_position` | Current race position |
| 315 | 1 | u8 | `accelerator` | Accelerator input (0-255) |
| 316 | 1 | u8 | `brake` | Brake input (0-255) |
| 317 | 1 | u8 | `clutch` | Clutch input (0-255) |
| 318 | 1 | u8 | `handbrake` | Handbrake input (0-255) |
| 319 | 1 | u8 | `gear` | Current gear (see enum below) |
| 320 | 1 | s8 | `steer` | Steering input (-127 to 127) |
| 321 | 1 | u8 | `driving_line` | Driving line assist status |
| 322 | 1 | u8 | `ai_brake` | AI brake assist status |

**Total Size: 323 bytes minimum**

## Enumeration Values

### Car Class (`car_class`)

| Value | Class |
|-------|-------|
| 0 | D |
| 1 | C |
| 2 | B |
| 3 | A |
| 4 | S1 |
| 5 | S2 |
| 6 | X |

### Drivetrain (`drivetrain`)

| Value | Type |
|-------|------|
| 0 | FWD (Front-Wheel Drive) |
| 1 | RWD (Rear-Wheel Drive) |
| 2 | AWD (All-Wheel Drive) |

### Gear (`gear`)

| Value | Gear |
|-------|------|
| 0 | Reverse |
| 1-10 | Gears 1-10 |
| 11 | Neutral |

### Car Category (`car_category`)

| Value | Category |
|-------|----------|
| 11 | Modern Super Cars |
| 12 | Retro Super Cars |
| 13 | Hyper Cars |
| 14 | Retro Saloons |
| 16 | Vans & Utility |
| 17 | Retro Sports Cars |
| 18 | Modern Sports Cars |
| 19 | Super Saloons |
| 20 | Classic Racers |
| 21 | Cult Cars |
| 25 | Super Hot Hatch |
| 29 | Rods & Customs |
| 30 | Retro Muscle |
| 31 | Modern Muscle |
| 32 | Retro Rally |
| 33 | Classic Rally |
| 34 | Rally Monsters |
| 35 | Modern Rally |
| 36 | GT Cars |
| 37 | Super GT |
| 38 | Extreme Offroad |
| 39 | Sports Utility Heroes |
| 40 | Offroad |
| 41 | Offroad Buggies |
| 42 | Classic Sports Cars |
| 43 | Track Toys |
| 44 | Vintage Racers |
| 45 | Trucks |

*Note: This list may not be complete. Additional categories may exist.*

## Unit Conversions

| Field | Raw Unit | Common Conversion |
|-------|----------|-------------------|
| `speed` | m/s | × 2.237 = mph, × 3.6 = km/h |
| `acceleration` | m/s² | ÷ 9.8 = g-force |
| `tire_temp` | Fahrenheit | (F - 32) × 5/9 = Celsius |
| `power` | Watts | ÷ 745.7 = Horsepower |
| `torque` | N·m | × 0.7376 = lb·ft |

## Coordinate System

- **X-axis**: Lateral (positive = right)
- **Y-axis**: Vertical (positive = up)
- **Z-axis**: Longitudinal (positive = forward)

For acceleration:
- Positive X = accelerating right (turning left)
- Positive Y = accelerating upward
- Positive Z = accelerating forward (braking shows negative)

## Example Code

### Elixir (used by Leadfoot)

```elixir
def parse_packet(
  <<racing::little-32, timestamp::little-32, max_rpm::little-float-32,
    idle_rpm::little-float-32, current_rpm::little-float-32,
    acceleration::bytes-12, velocity::bytes-12, ...>>
) do
  # Parse compound types
  acceleration = parse_triple(acceleration)  # Returns %{x: _, y: _, z: _}
  # ...
end
```

### Python

```python
import struct

def parse_packet(data):
    # Unpack first section
    racing, timestamp, max_rpm, idle_rpm, current_rpm = struct.unpack('<iifff', data[0:20])

    # Unpack vectors (12 bytes each = 3 floats)
    acceleration = struct.unpack('<fff', data[20:32])
    velocity = struct.unpack('<fff', data[32:44])

    # Unpack corners (16 bytes each = 4 floats)
    # Order: front_left, front_right, rear_left, rear_right
    tire_temps = struct.unpack('<ffff', data[268:284])

    # Unpack input section
    accelerator, brake, clutch, handbrake, gear, steer = struct.unpack('<BBBBBb', data[315:321])

    return {
        'racing': racing,
        'timestamp': timestamp,
        'rpm': current_rpm,
        'speed_mph': struct.unpack('<f', data[256:260])[0] * 2.237,
        'gear': 'N' if gear == 11 else ('R' if gear == 0 else str(gear)),
        # ... etc
    }
```

### C/C++

```c
#pragma pack(push, 1)
typedef struct {
    int32_t racing;
    uint32_t timestamp;
    float max_rpm;
    float idle_rpm;
    float current_rpm;
    float acceleration[3];
    float velocity[3];
    float angular_velocity[3];
    float yaw_pitch_roll[3];
    float norm_suspension[4];
    float tire_slip_ratio[4];
    float wheel_rotation[4];
    float on_rumble[4];
    float in_puddle[4];
    float surface_rumble[4];
    float tire_slip_angle[4];
    float tire_comb_slip[4];
    float suspension_travel[4];
    int32_t car_id;
    int32_t car_class;
    int32_t car_performance;
    int32_t drivetrain;
    int32_t num_cylinders;
    int32_t car_category;
    uint8_t unknown1[4];
    uint8_t unknown2[4];
    float world_position[3];
    float speed;
    float power;
    float torque;
    float tire_temp[4];
    float boost;
    float fuel;
    float distance;
    float best_lap_time;
    float last_lap_time;
    float current_lap_time;
    float current_race_time;
    uint16_t lap;
    uint8_t race_position;
    uint8_t accelerator;
    uint8_t brake;
    uint8_t clutch;
    uint8_t handbrake;
    uint8_t gear;
    int8_t steer;
    uint8_t driving_line;
    uint8_t ai_brake;
} ForzaPacket;
#pragma pack(pop)
```

## Notes

- The `racing` field is 0 when in menus, photo mode, or paused, and 1 during active gameplay
- Lap times are 0.0 when not applicable (e.g., free roam)
- The `timestamp` field continues incrementing even when paused but stops when the game is minimized
- The `unknown1` and `unknown2` fields appear to change during vehicle collisions but their exact purpose is not documented
- Wheel order for all "Corners" types is: Front Left, Front Right, Rear Left, Rear Right

## Compatibility

This format is compatible with:
- Forza Horizon 5
- Forza Horizon 4
- Forza Motorsport 7+
- Forza Motorsport (2023)

Earlier Forza games may use different packet formats.

## References

- Leadfoot implementation: `lib/leadfoot/parse_packet.ex`
- Translation helpers: `lib/leadfoot/translation.ex`
