defmodule RmcWeb.TelemetryChannel do
  @moduledoc false
  use Phoenix.Channel

  def join("telemetry:f1", _message, socket) do
    {:ok, socket}
  end


end
