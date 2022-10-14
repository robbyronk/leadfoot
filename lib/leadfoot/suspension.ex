defmodule Leadfoot.Suspension do
  @moduledoc false

  @doc """
  Takes in a corner weight in kg and spring rate in N/mm and returns the suspension frequency.

      iex> Float.round(Leadfoot.Suspension.frequency(100, 400), 2)
      2.52
  """
  def frequency(spring_rate, m) do
    k = spring_rate * 1000
    :math.sqrt(k / m) / (:math.pi() * 2)
  end
end
