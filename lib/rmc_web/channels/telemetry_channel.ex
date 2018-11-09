defmodule RmcWeb.TelemetryChannel do
  @moduledoc false
  use Phoenix.Channel

  def join("telemetry:session", _message, socket) do
    {:ok, socket}
  end


end
