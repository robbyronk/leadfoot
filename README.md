# Leadfoot Telemetry

*Real-time telemetry and tuning tools for Forza Horizon 5*

Leadfoot is a web-based telemetry system and tuning toolkit for Forza Horizon 5. It receives real-time UDP data from Forza and provides live visualization, analysis tools, and a lap time leaderboard to help you tune your cars and improve your driving.

![Engine force at the wheels, by speed for a Subaru 22B](./22b-optimal-forces.svg)

## Features

### Live Telemetry
- **Live Dashboard** - Real-time display of telemetry data including tire temps, speed, RPM, and more (requires login)
- **Lap Time Tracking** - Record and compare your best lap times with car, track, and tune details

### Analysis & Tuning Tools
- **Dynamometer** - Analyze engine performance with force curves by speed
- **Gear Ratios** - Optimize gear ratios for your car and track
- **Suspension Calculator** - Calculate optimal suspension settings
- **Launch Tuning** - Fine-tune your launch control settings (requires login)
- **Lap Times Leaderboard** - Track and compare lap times across different cars and tracks

### User Features
- User registration and authentication
- Personal lap time tracking
- Video link integration for lap replays

## Quick Start

### Prerequisites

- **Elixir** 1.14 or higher - [Installation guide](https://elixir-lang.org/install.html)
- A computer to run Leadfoot (can be the same or different from your gaming PC)
- Forza Horizon 5

### Installation

1. **Clone or download this repository**
   ```bash
   git clone https://github.com/robbyronk/leadfoot.git
   cd leadfoot
   ```

2. **Install dependencies and set up the database**
   ```bash
   mix setup
   ```

3. **Start the Phoenix server**
   ```bash
   mix phx.server
   ```

4. **Open your browser**

   Navigate to [`http://localhost:4000`](http://localhost:4000)

### Connecting Forza Horizon 5

1. In Forza's **HUD and Gameplay** settings, find the **"Data Out"** section
2. **Enable Data Out**
3. Set the **IP address** to the computer running Leadfoot:
   - If running on the same PC: `127.0.0.1`
   - If running on a different PC: Use that computer's local IP address
4. Set the **port** to `21337`

#### Windows Firewall Note

If you're running Leadfoot on the same Windows computer as Forza, you may need to configure the Windows Firewall to allow loopback UDP traffic. Follow [these instructions](https://www.xsimulator.net/community/faq/forza-4.338/) (written for Forza 4 but applies to Forza 5 as well).

## Development

### Available Commands

- `mix setup` - Install dependencies and set up database
- `mix test` - Run tests
- `mix ecto.reset` - Reset database
- `mix phx.server` - Start Phoenix server

### Tech Stack

- **Phoenix Framework** - Web framework
- **Phoenix LiveView** - Real-time interactive UI
- **Ecto** - Database wrapper (SQLite for development, PostgreSQL for production)
- **Tailwind CSS** - Styling
- **Contex** - Chart generation

## Why Elixir?

Elixir sits at the intersection of **fun** and **fast**. It's one of the few languages that is:
- **Fun to use** - Elegant, expressive syntax with a great developer experience
- **Fast to develop with** - Phoenix LiveView enables rapid development of real-time features
- **Scales effortlessly** - Handles thousands of telemetry events per second with ease

The Erlang VM's concurrency model makes it perfect for handling real-time UDP telemetry streams while serving multiple users simultaneously.

## License

See [LICENSE](./LICENSE) for details.

## Contributing

Contributions are welcome! Feel free to open issues or submit pull requests.