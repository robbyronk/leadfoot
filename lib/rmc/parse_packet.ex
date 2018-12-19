defmodule Rmc.ParsePacket do
  @moduledoc """
    Sends the packet to the correct parser
  """
  alias Rmc.DataIn
  alias Rmc.FOne2018.{Motion, Session, Laps, Event, Participants, CarSetups, Telemetries, CarStatuses}

  use GenStage

  def start_link do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    state = %{producer: DataIn}

    {:producer_consumer, :_state, subscribe_to: [DataIn]}
  end

  def handle_events(packets, _from, state) do
    parsed_packets = Enum.map(packets, &parse_packet/1)

    {:noreply, parsed_packets, state}
  end

  def parse_packet(
        <<
          2018::unsigned-little-size(16),
          1::unsigned-size(8),
          packet_id::unsigned-size(8),
          _rest::binary
        >> = data
      ) do
    case packet_id do
      0 -> Motion.parse_packet(data)
      1 -> Session.parse_packet(data)
      2 -> Laps.parse_packet(data)
      3 -> Event.parse_packet(data)
      4 -> Participants.parse_packet(data)
      5 -> CarSetups.parse_packet(data)
      6 -> Telemetries.parse_packet(data)
      7 -> CarStatuses.parse_packet(data)
      _ -> nil
    end
  end
end
