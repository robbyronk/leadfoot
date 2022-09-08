defmodule Leadfoot.ReadFile do
  @moduledoc """
  Reads packets from a file and publishes them to pubsub.
  """

  # todo move dyno pulls to priv dir

  # priv_dir = :code.priv_dir(:leadfoot) |> to_string()
  # File.read!(priv_dir <> "/dyno-pulls/xyz")

  # ms
  @pace 6

  use GenServer
  alias Leadfoot.ParsePacket
  alias Phoenix.PubSub

  def start_link(state \\ %{}, opts \\ []) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  @impl true
  def init(_opts) do
    {:ok, %{}, {:continue, :open_file}}
  end

  @impl true
  def handle_continue(:open_file, state) do
    file = File.open!("dyno-pulls/4rotor-dyno.forza", [:read])

    event =
      read_packet(file)
      |> ParsePacket.parse_packet()

    PubSub.broadcast(Leadfoot.PubSub, "session", {:event, event})
    Process.send_after(self(), :read_and_publish, @pace)

    {
      :noreply,
      state
      |> Map.put(:file, file)
      |> Map.put(:last_event, event)
    }
  end

  @impl true
  def handle_info(:read_and_publish, state) do
    event = read_packet(state.file)

    if event != :eof do
      event = ParsePacket.parse_packet(event)
      PubSub.broadcast(Leadfoot.PubSub, "session", {:event, event})
      Process.send_after(self(), :read_and_publish, get_pace(state.last_event, event))

      {
        :noreply,
        state
        |> Map.put(:last_event, event)
      }
    else
      {:noreply, state}
    end
  end

  def get_pace(%{current_race_time: last_race_time}, %{current_race_time: next_race_time}) do
    cond do
      last_race_time == 0.0 -> @pace
      next_race_time == 0.0 -> @pace
      true -> round((next_race_time - last_race_time) * 1000)
    end
  end

  def read_packet(file) do
    case IO.binread(file, 2) do
      :eof -> :eof
      <<size::16>> -> IO.binread(file, size)
    end
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
end
