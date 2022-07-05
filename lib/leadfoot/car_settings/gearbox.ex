defmodule Leadfoot.CarSettings.Gearbox do
  @moduledoc false

  defstruct [
    :final,
    :gear1,
    :gear2,
    :gear3,
    :gear4,
    :gear5,
    :gear6,
    :gear7,
    :gear8,
    :gear9,
    :gear10
  ]

  @types %{
    final: :float,
    gear1: :float,
    gear2: :float,
    gear3: :float,
    gear4: :float,
    gear5: :float,
    gear6: :float,
    gear7: :float,
    gear8: :float,
    gear9: :float,
    gear10: :float
  }

  import Ecto.Changeset

  def changeset(%__MODULE__{} = gearbox, attrs) do
    {gearbox, @types}
    |> cast(attrs, Map.keys(@types))
    |> validate_required([:final, :gear1])
  end

  def get_gears(%__MODULE__{} = gearbox) do
    gears = [
      :gear1,
      :gear2,
      :gear3,
      :gear4,
      :gear5,
      :gear6,
      :gear7,
      :gear8,
      :gear9,
      :gear10
    ]

    Enum.reduce_while(gears, [], fn gear, acc ->
      case Map.fetch!(gearbox, gear) do
        nil -> {:halt, acc}
        ratio -> {:cont, [ratio | acc]}
      end
    end)
    |> Enum.reverse()
  end
end
