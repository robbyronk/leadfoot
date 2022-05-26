defmodule RaceControl.ReadFile do
  @moduledoc false

#  RaceControl.ReadFile.read("session.forza")

  def read(file_name) do
    f = File.read!(file_name)
    read_packets(f)
  end

  def read_packets(<<>>), do: []
  def read_packets(<<
    packet_size::16,
    packet::bytes-size(packet_size),
    rest::binary
  >>), do: [packet | read_packets(rest)]
end
