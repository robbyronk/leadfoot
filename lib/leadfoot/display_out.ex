defmodule Leadfoot.DisplayOut do
  @moduledoc """
  Sends commands to an Arduino to light up an LED based on the direction and magnitude of g forces on the car.
  """

  use GenServer

  alias Phoenix.PubSub

  @leds 16
  @max_bright 255
  @max_g 4
  @g 9.8

  def start_link(state \\ %{}, opts \\ []) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  @impl true
  def init(_state) do
    {:ok, pid} = Circuits.UART.start_link()
    # todo support selecting a device at run time
    Circuits.UART.open(pid, "ttyACM0", speed: 115_200, active: true)
    PubSub.subscribe(Leadfoot.PubSub, "session")

    {:ok, %{uart_pid: pid}}
  end

  def longitudinal(event), do: event[:acceleration][:z]

  def lateral(event), do: event[:acceleration][:x]

  def get_accel_led(event) do
    z = longitudinal(event)
    x = lateral(event)
    # angle is `atan2(x, y) * 180 / pi`
    led = round(Math.atan2(x, z) * @leds / 2 / :math.pi() + @leds / 2)
    IO.inspect(led, label: "led")
  end

  def get_accel_magnitude(event) do
    z = longitudinal(event)
    x = lateral(event)
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

  @impl true
  def handle_info({:event, event}, state) do
    led = get_accel_led(event)
    mag = get_accel_magnitude(event)
    Circuits.UART.write(state.uart_pid, led_command(led, get_accel_color(mag)))
    {:noreply, state}
  end

  @impl true
  def handle_info({:circuits_uart, "ttyACM0", data}, state) do
    # this handles any incoming data that the Arduino sent
    IO.inspect(data, label: "serial echo")
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
end
