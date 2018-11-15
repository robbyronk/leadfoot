defmodule Rmc.Serial do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: :serial)
  end

  def init (:ok) do
    {:ok, pid} = Nerves.UART.start_link()

    Nerves.UART.open(pid, "/dev/cu.uart-77FF4A7AB7552107", speed: 9600, active: true)

    {:ok, %{pid: pid}}
  end

  def handle_cast({:put, %{packet_header: packet_header, telemetries: telemetries}}, %{pid: pid} = state) do
    %{player_car_index: player_car_index} = packet_header
    case Enum.fetch(telemetries, player_car_index) do
      {:ok, %{rev_lights_percent: r, speed: s, gear: g}} ->
        IO.inspect("rev #{r}, speed #{s}, gear #{g} (#{"#{r},#{s},#{g},"})")
        Nerves.UART.write(pid, <<r>> <> <<s::16>> <> <<g>> <> "\n")
      :error -> IO.inspect("Telemetry #{player_car_index} not found")
    end
    {:noreply, state}
  end

  def handle_info(_, state), do: {:noreply, state}
end
