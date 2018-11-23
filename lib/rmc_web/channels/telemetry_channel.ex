defmodule RmcWeb.TelemetryChannel do
  @moduledoc false
  use Phoenix.Channel

  def join("telemetry:" <> _, _message, socket) do
    {:ok, socket}
  end
end
