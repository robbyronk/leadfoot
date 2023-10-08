defmodule Leadfoot.CarSettings.Gearbox do
  @moduledoc false

  import Ecto.Changeset

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

    gears
    |> Enum.reduce_while([], fn gear, acc ->
      case Map.fetch!(gearbox, gear) do
        nil -> {:halt, acc}
        ratio -> {:cont, [ratio | acc]}
      end
    end)
    |> Enum.reverse()
  end

  def fill_gears(%__MODULE__{} = gearbox, []), do: gearbox

  def fill_gears(%__MODULE__{} = gearbox, [gear | rest]) do
    cond do
      is_nil(gearbox.gear1) -> fill_gears(%{gearbox | gear1: gear}, rest)
      is_nil(gearbox.gear2) -> fill_gears(%{gearbox | gear2: gear}, rest)
      is_nil(gearbox.gear3) -> fill_gears(%{gearbox | gear3: gear}, rest)
      is_nil(gearbox.gear4) -> fill_gears(%{gearbox | gear4: gear}, rest)
      is_nil(gearbox.gear5) -> fill_gears(%{gearbox | gear5: gear}, rest)
      is_nil(gearbox.gear6) -> fill_gears(%{gearbox | gear6: gear}, rest)
      is_nil(gearbox.gear7) -> fill_gears(%{gearbox | gear7: gear}, rest)
      is_nil(gearbox.gear8) -> fill_gears(%{gearbox | gear8: gear}, rest)
      is_nil(gearbox.gear9) -> fill_gears(%{gearbox | gear9: gear}, rest)
      is_nil(gearbox.gear10) -> fill_gears(%{gearbox | gear10: gear}, rest)
    end
  end
end
