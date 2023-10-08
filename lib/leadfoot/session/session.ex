defmodule Leadfoot.Session.Session do
  @moduledoc """
  Process that collects data for racing, tuning and analysis.
  """

  use GenServer, restart: :transient

  alias Leadfoot.ParsePacket
  alias Leadfoot.Tuning.Launch
  alias Phoenix.PubSub

  require Logger

  @timeout :timer.minutes(30)

  @registry Leadfoot.Session.Registry
  @supervisor Leadfoot.Session.Supervisor

  def start(id) do
    opts = [
      id: id,
      name: {:via, Registry, {@registry, id}}
    ]

    DynamicSupervisor.start_child(@supervisor, {__MODULE__, opts})
  end

  def lookup(id) do
    case Registry.lookup(@registry, id) do
      [{pid, _}] -> {:ok, pid}
      [] -> {:error, :not_found}
    end
  end

  def join(id) do
    with {:error, :not_found} <- lookup(id) do
      start(id)
    end
  end

  def get_state(id) do
    with {:ok, pid} <- join(id) do
      GenServer.call(pid, :get_state)
    end
  end

  def change_port(id, port) do
    with {:ok, pid} <- join(id) do
      GenServer.call(pid, {:change_port, port})
    end
  end

  def start_link(opts) do
    {name, opts} = Keyword.pop(opts, :name)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  @impl true
  def init(id: id) do
    state = %{
      id: id,
      udp_port: random_port(),
      udp_port_status: :closed
    }

    {:ok, state, {:continue, :open_port}}
  end

  @impl true
  def handle_continue(:open_port, state) do
    {:ok, _pid} = Launch.start_link(%{user_id: state.id})
    state = open_udp(state)

    if state.udp_port_status == :ok do
      {:noreply, state, @timeout}
    else
      {:noreply, %{state | udp_port: random_port()}, {:continue, :open_port}}
    end
  end

  @impl true
  def handle_info(:timeout, state) do
    Logger.info("shutting down #{state.id}")

    {:stop, :normal, state}
  end

  @impl true
  def handle_info({:udp, _socket, _ip, _port, data}, state) do
    event = ParsePacket.parse_packet(data)
    PubSub.broadcast(Leadfoot.PubSub, "session:#{state.id}", {:event, event})

    {:noreply, state, @timeout}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state, state, @timeout}
  end

  @impl true
  def handle_call({:change_port, port}, _from, state) do
    state = open_udp(%{state | udp_port: port})
    {:reply, state, state, @timeout}
  end

  defp random_port do
    49_584
    #    Enum.random(10000..65000)
  end

  defp get_udp_ip do
    udp_ip = Application.fetch_env!(:leadfoot, :udp_ip)

    if is_binary(udp_ip) do
      {:ok, u} = :inet.getaddr(to_charlist(udp_ip), :inet)
      u
    else
      udp_ip
    end
  end

  defp open_udp(state) do
    new_state =
      case :gen_udp.open(state.udp_port, mode: :binary, ip: get_udp_ip()) do
        {:ok, socket} ->
          %{
            socket: socket,
            udp_port_status: :ok
          }

        {:error, reason} ->
          %{
            socket: nil,
            udp_port_status: {:error, reason}
          }
      end

    Map.merge(state, new_state)
  end
end
