defmodule Leadfoot.ReadFile do
  @moduledoc """
  Reads packets from a file, with optional pacing, and publishes them to PubSub or UDP.

  Opens a file, maybe opens an UDP socket.

  Reads, parses a packet.

  Publishes that packet.
    
  Maybe waits a few ms, then repeats the read then publish.
  """

  # todo move dyno pulls to priv dir

  # priv_dir = :code.priv_dir(:leadfoot) |> to_string()
  # File.read!(priv_dir <> "/dyno-pulls/xyz")

  # ms
  @pace 6

  @server Leadfoot.ReadFile

  @initial_state %{
    use_pacing: true,
    # ms
    pace: 6,
    publish_to: :pubsub,
    filename: "session.forza",
    # pid of open file
    file: nil,
    # used for pacing
    last_event: nil,
    udp: nil,
    udp_address: {127, 0, 0, 1},
    udp_port: 21_337
  }

  use GenServer
  alias Leadfoot.ParsePacket
  alias Phoenix.PubSub

  def start_link(state \\ %{}) do
    GenServer.start_link(__MODULE__, state, name: @server)
  end

  @impl true
  def init(state) do
    {:ok, Map.merge(@initial_state, state), {:continue, :open_file}}
  end

  @impl true
  def handle_continue(:open_file, state) do
    file = File.open!(state.filename, [:read])

    continue =
      case state.publish_to do
        :udp -> :open_udp
        :pubsub -> :first_read
      end

    {
      :noreply,
      %{state | file: file},
      {:continue, continue}
    }
  end

  @impl true
  def handle_continue(:open_udp, state) do
    {:ok, socket} = :gen_udp.open(8680)

    {
      :noreply,
      %{state | udp: socket},
      {:continue, :first_read}
    }
  end

  @impl true
  def handle_continue(:first_read, state) do
    packet = read_packet(state.file)
    event = ParsePacket.parse_packet(packet)
    publish(state, event, packet)
    next(state, event)

    {
      :noreply,
      %{state | last_event: event}
    }
  end

  @impl true
  def handle_info(:read_and_publish, state) do
    packet = read_packet(state.file)

    if packet != :eof do
      event = ParsePacket.parse_packet(packet)
      publish(state, event, packet)
      next(state, event)

      {
        :noreply,
        %{state | last_event: event}
      }
    else
      {:stop, :normal, state}
    end
  end

  def get_pace(%{current_race_time: last_race_time}, %{current_race_time: next_race_time}, pace) do
    cond do
      last_race_time == 0.0 -> pace
      next_race_time == 0.0 -> pace
      true -> round((next_race_time - last_race_time) * 1000)
    end
  end

  def publish(%{publish_to: :pubsub}, event, _packet) do
    PubSub.broadcast(Leadfoot.PubSub, "session", {:event, event})
  end

  def publish(%{publish_to: :udp, udp: socket, udp_address: address, udp_port: port}, _event, packet) do
    :gen_udp.send(socket, address, port, packet)
  end

  def next(%{use_pacing: true, last_event: nil, pace: pace}, _event) do
    Process.send_after(self(), :read_and_publish, pace)
  end

  def next(%{use_pacing: true, last_event: last_event, pace: pace}, event) do
    Process.send_after(self(), :read_and_publish, get_pace(last_event, event, pace))
  end

  def next(%{use_pacing: false}, _event) do
    send(self(), :read_and_publish)
  end

  def read_packet(file) do
    case IO.binread(file, 2) do
      :eof -> :eof
      <<size::16>> -> IO.binread(file, size)
    end
  end
end
