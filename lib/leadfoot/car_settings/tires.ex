defmodule Leadfoot.CarSettings.Tires do
  @moduledoc false

  defstruct [:width, :ratio, :size]
  @types %{width: :integer, ratio: :integer, size: :integer}

  import Ecto.Changeset

  def changeset(%__MODULE__{} = tires, attrs) do
    {tires, @types}
    |> cast(attrs, Map.keys(@types))
    |> validate_required(Map.keys(@types))
  end

  def get_tire_height(%__MODULE__{} = tires) do
    get_tire_height(tires.width, tires.ratio, tires.size)
  end

  @doc """
  Returns tire height in meters given the 3 parts of a standard tire size.

  The format of a standard tire size is aaa/bbRcc.

  - aaa is the tire width in millimeters, ex: 235 or 275
  - bb is the tire aspect ratio, ex: 40 or 65
  - cc is the wheel size in inches, ex: 16 or 20

      iex> Float.round(Leadfoot.GearRatios.get_tire_height(235, 40, 17), 2)
      0.62
  """
  def get_tire_height(width, aspect_ratio, wheel_size) do
    wheel_size * 0.0254 + width * (aspect_ratio / 100) * 2 / 1000
  end
end
