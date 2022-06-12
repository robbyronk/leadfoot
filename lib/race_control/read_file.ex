defmodule RaceControl.ReadFile do
  @moduledoc """
  Reads packets from a file and publishes them to pubsub.
  """

  # ms
  @pace 6

  # todo change this to read packet, then wait, then send
  #

  use GenServer
  alias RaceControl.ParsePacket
  alias Phoenix.PubSub

  def start_link(state \\ %{}, opts \\ []) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(_opts) do
    {:ok, %{}, {:continue, :open_file}}
  end

  def get_pace(%{current_race_time: last_race_time}, %{current_race_time: next_race_time}) do
    pace =
      cond do
        last_race_time == 0.0 -> @pace
        next_race_time == 0.0 -> @pace
        true -> (next_race_time - last_race_time) * 1000
      end

    round(pace)
  end

  def handle_continue(:open_file, state) do
    {:ok, file} = File.open("session.forza", [:read])
    event = read_packet(file)
    PubSub.broadcast(RaceControl.PubSub, "session", {:event, event})
    Process.send_after(self(), :read_and_publish, @pace)

    {
      :noreply,
      state
      |> Map.put(:file, file)
      |> Map.put(:last_event, event)
    }
  end

  def handle_info(:read_and_publish, state) do
    event = read_packet(state.file)
    # todo handle :eof from read_packet
    PubSub.broadcast(RaceControl.PubSub, "session", {:event, event})
    Process.send_after(self(), :read_and_publish, get_pace(state.last_event, event))

    {
      :noreply,
      state
      |> Map.put(:last_event, event)
    }
  end

  def read(file_name) do
    f = File.read!(file_name)
    read_packets(f)
  end

  def read_packets(<<>>), do: []

  def read_packets(<<
        packet_size::16,
        packet::bytes-size(packet_size),
        rest::binary
      >>) do
    [ParsePacket.parse_packet(packet) | read_packets(rest)]
  end

  def read_packet(file) do
    # todo handle :eof from binread
    <<size::16>> = IO.binread(file, 2)

    packet = IO.binread(file, size)
    ParsePacket.parse_packet(packet)
  end
end
