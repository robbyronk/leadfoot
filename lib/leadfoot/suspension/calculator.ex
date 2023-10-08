defmodule Leadfoot.Suspension.Calculator do
  @moduledoc """
  Calculates the suspension natural frequency given valid inputs.
  """

  import Ecto.Changeset

  alias Leadfoot.Suspension

  defstruct [
    :front_downforce,
    :rear_downforce,
    :front_spring_rate,
    :rear_spring_rate,
    :mass,
    :front_distribution
  ]

  @types %{
    front_downforce: :float,
    rear_downforce: :float,
    front_spring_rate: :float,
    rear_spring_rate: :float,
    mass: :integer,
    front_distribution: :integer
  }

  def changeset(%__MODULE__{} = suspension, attrs) do
    {suspension, @types}
    |> cast(attrs, Map.keys(@types))
    |> validate_number(:front_downforce, greater_than_or_equal_to: 0.0)
    |> validate_number(:rear_downforce, greater_than_or_equal_to: 0.0)
    |> validate_number(:front_spring_rate, greater_than: 0.0)
    |> validate_number(:rear_spring_rate, greater_than: 0.0)
    |> validate_number(:mass, greater_than: 0)
    |> validate_number(:front_distribution, greater_than: 0, less_than: 100)
    |> validate_required(Map.keys(@types))
  end

  def get_frequencies(%__MODULE__{} = values) do
    # ignoring unsprung weight for now
    front_mass = values.mass * (values.front_distribution / 100)
    rear_mass = values.mass - front_mass

    {
      Suspension.frequency(values.front_spring_rate, front_mass / 2),
      Suspension.frequency(values.rear_spring_rate, rear_mass / 2),
      Suspension.frequency(values.front_spring_rate, (values.front_downforce + front_mass) / 2),
      Suspension.frequency(values.rear_spring_rate, (values.rear_downforce + rear_mass) / 2)
    }
  end
end
