defmodule Leadfoot.Session.Session do
  @moduledoc """
  Process that collects data for racing, tuning and analysis.
  """

  require Logger

  use GenServer, restart: :transient
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

  def get_udp_status(id) do
    with {:ok, pid} <- lookup(id) do
      GenServer.call(pid, :get_udp_status)
    end
  end

  def change_port(id, port) do
    with {:ok, pid} <- lookup(id) do
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
      udp_port: 21337,
      udp_port_status: :closed
    }

    {:ok, state |> open_udp(state.udp_port), @timeout}
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
  def handle_call(:get_udp_status, _from, state) do
    {:reply, state.udp_port_status, state, @timeout}
  end

  @impl true
  def handle_call({:change_port, port}, from, state) do
    state = open_udp(state, port)
    {:reply, state, state, @timeout}
  end

  defp get_udp_ip() do
    udp_ip = Application.fetch_env!(:leadfoot, :udp_ip)

    if is_binary(udp_ip) do
      {:ok, u} = :inet.getaddr(to_charlist(udp_ip), :inet)
      u
    else
      udp_ip
    end
  end

  defp open_udp(state, port) do
    new_state =
      case :gen_udp.open(port, mode: :binary, ip: get_udp_ip()) do
        {:ok, socket} ->
          %{
            socket: socket,
            udp_port: port,
            udp_port_status: :ok
          }

        {:error, reason} ->
          %{
            socket: nil,
            udp_port: port,
            udp_port_status: {:error, reason}
          }
      end

    Map.merge(state, new_state)
  end
end
