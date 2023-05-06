alias Leadfoot.GearRatios
alias Leadfoot.ReadFile
alias Leadfoot.ReadUdp
alias Leadfoot.Session.Session

defmodule App do
  def restart do
    Application.stop(:leadfoot)
    recompile()
    Application.ensure_all_started(:leadfoot)
  end
end
