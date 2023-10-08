alias Leadfoot.GearRatios
alias Leadfoot.ReadFile
alias Leadfoot.ReadUdp
alias Leadfoot.Session.Session

defmodule App do
  @moduledoc """
  Type `App.restart` in iex to recompile/restart the whole app.
  """
  def restart do
    Application.stop(:leadfoot)
    recompile()
    Application.ensure_all_started(:leadfoot)
  end
end
