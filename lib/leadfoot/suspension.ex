defmodule Leadfoot.Suspension do
  @moduledoc false

  @doc """
  Takes in a corner weight in kg and spring rate in kgf/mm and returns the suspension frequency

      iex> Float.round(Leadfoot.Suspension.frequency(100, 400), 2)
      2.49


  """
  def frequency(spring_rate, m) do
    # k = spring rate in N/m
    # m = mass in kg
    k = spring_rate * 980
    1 / (2 * :math.pi()) * :math.sqrt(k / m)
  end
end
