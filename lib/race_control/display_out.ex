defmodule RaceControl.DisplayOut do
  @moduledoc false

  use GenServer
  alias Phoenix.PubSub

  @leds 16
  @max_bright 255
  @max_g 4
  @g 9.8

  def scratch() do
    # RaceControl.ReadFile.start_link()
    # r RaceControl.DisplayOut

    {:ok, pid} = RaceControl.DisplayOut.start_link()
    GenServer.cast(pid, :close)
  end

  def start_link(state \\ %{}, opts \\ []) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  @impl true
  def init(_state) do
    {:ok, pid} = Circuits.UART.start_link()
    Circuits.UART.open(pid, "ttyACM0", speed: 115_200, active: true)
    PubSub.subscribe(RaceControl.PubSub, "session")

    {:ok, %{uart_pid: pid}}
  end

  def get_accel_led(event) do
    # forwards
    z = event[:acceleration][:z]
    # lateral
    x = event[:acceleration][:x]
    # angle is `atan2(x, y) * 180 / pi`
    led = round(Math.atan2(x, z) * @leds / 2 / :math.pi() + @leds / 2)
    IO.inspect(round(led), label: "led")
  end

  def get_accel_magnitude(event) do
    # forwards
    z = event[:acceleration][:z]
    # lateral
    x = event[:acceleration][:x]
    mag = :math.sqrt(x ** 2 + z ** 2) / @g
    IO.inspect(mag, label: "mag")
  end

  def c(m), do: round(m / @max_g * @max_bright)

  def get_accel_color(mag) do
    cond do
      mag < 0.1 -> {0, 0, 0}
      mag < 1 -> {0, 0, c(mag)}
      mag < 1.5 -> {0, c(mag), c(mag)}
      mag < 2 -> {0, c(mag), 0}
      mag < @max_g -> {c(mag), c(mag), c(mag)}
      true -> {c(mag), 0, 0}
    end
  end

  def handle_info({:event, event}, state) do
    led = get_accel_led(event)
    mag = get_accel_magnitude(event)
    Circuits.UART.write(state.uart_pid, led_command(led, get_accel_color(mag)))
    {:noreply, state}
  end

  @impl true
  def handle_cast(:close, state) do
    Circuits.UART.close(state.uart_pid)
    {:noreply, state}
  end

  def led_command(led, {red, green, blue} \\ {255, 255, 255}) do
    "L" <> <<led, red, green, blue>>
  end

  @impl true
  def handle_info({:circuits_uart, "ttyACM0", data}, state) do
    IO.inspect(data, label: "serial echo")
    {:noreply, state}
  end
end
