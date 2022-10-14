# Leadfoot Telemetry

*For Forza Horizon 5*

- Live dashboard, including tire temps and last lap time.
- Analyze recorded telemetry

Engine force at the wheels, by speed for a Subaru 22B:
![force by speed for a Subaru 22B](./22b-optimal-forces.svg)


## Why Elixir

Elixir is at the intersection of fun and fast. There aren't many languages that are both fun to use, fast to develop
with and scales to many, many events per second. 

## Setting up Leadfoot

You'll need a computer to run it on. It doesn't have to be the same computer that you run Forza on.

1. Install Elixir
2. Download Leadfoot
3. Run Leadfoot
4. Connect Forza

### Installing Elixir

Go [here](https://elixir-lang.org/install.html) and pick your OS. There's a simple installer for Win, Mac or Linux.

### Download Leadfoot

Open the [GitHub repository](https://github.com/robbyronk/leadfoot) and click the green code button, then click 
download zip. Unzip that.

### Running Leadfoot

Open your Terminal or Command Line and `cd` to the directory where you unzipped Leadfoot. 
Run `mix deps.get` then `mix phx.server`. If you are running this for the first time, wait about a minute for the code
to compile. When compilation has finished, open [http://localhost:4000](http://localhost:4000)

### Connecting Forza

In your HUD and Gameplay settings, look for "Data Out". Turn that on and set the IP to the IP of the computer running Leadfoot. If
it's running on the Windows computer that you are playing on, this will be 127.0.0.1. Set the port to 21337.

If you are running Leadfoot on the same Windows computer, there's an extra step to allow Forza to communicate to Leadfoot.
Follow the instructions [here](https://www.xsimulator.net/community/faq/forza-4.338/). It says Forza 4 but it's the same
process for Forza 5.