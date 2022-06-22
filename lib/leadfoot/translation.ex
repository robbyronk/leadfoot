defmodule Leadfoot.Translation do
  @moduledoc """
  Contains functions to convert raw values into human readable values.
  """

  @doc """
  Given meters per second, returns miles per hour.
  """
  def speed(value) do
    round(value * 2.237)
  end

  @doc """
  Given meters per second^2, returns g.
  """
  def acceleration(value) do
    Float.round(value / 9.8, 2)
  end

  @doc """
  Not sure why but tire temps are in F in the telemetry. Returns temp as C.
  """
  def tire_temp(value) do
    round((value - 32) * 5 / 9)
  end

  @doc """
  Returns string describing drivetrain.
  """
  def drivetrain(index) do
    case index do
      0 -> "FWD"
      1 -> "RWD"
      2 -> "AWD"
      _ -> "UNK"
    end
  end

  @doc """
  Returns string describing selected gear.
  """
  def gear(num) do
    case num do
      11 -> "N"
      0 -> "R"
      _ -> "#{num}"
    end
  end

  @doc """
  Returns string describing car class, D through X.
  """
  def car_class(index) do
    case index do
      0 -> "D"
      1 -> "C"
      2 -> "B"
      3 -> "A"
      4 -> "S1"
      5 -> "S2"
      6 -> "X"
      _ -> "U#{index}"
    end
  end

  @doc """
  Returns string describing car category. IE: "Hyper Cars" or "Retro Saloons"
  """
  def car_category(index) do
    # todo is this complete?
    case index do
      11 -> "Modern Super Cars"
      12 -> "Retro Super Cars"
      13 -> "Hyper Cars"
      14 -> "Retro Saloons"
      16 -> "Vans & Utility"
      17 -> "Retro Sports Cars"
      18 -> "Modern Sports Cars"
      19 -> "Super Saloons"
      20 -> "Classic Racers"
      21 -> "Cult Cars"
      25 -> "Super Hot Hatch"
      29 -> "Rods & Customs"
      30 -> "Retro Muscle"
      31 -> "Modern Muscle"
      32 -> "Retro Rally"
      33 -> "Classic Rally"
      34 -> "Rally Monsters"
      35 -> "Modern Rally"
      36 -> "GT Cars"
      37 -> "Super GT"
      38 -> "Extreme Offroad"
      39 -> "Sports Utility Heroes"
      40 -> "Offroad"
      41 -> "Offroad Buggies"
      42 -> "Classic Sports Cars"
      43 -> "Track Toys"
      44 -> "Vintage Racers"
      45 -> "Trucks"
      _ -> "Unknown #{index}"
    end
  end

  # todo use Time module?

  @one_minute 60
  @one_hour 3600

  def to_hh_mm_ss(seconds) when seconds >= @one_hour do
    h = div(seconds, @one_hour)

    m =
      seconds
      |> rem(@one_hour)
      |> div(@one_minute)
      |> pad_int()

    s =
      seconds
      |> rem(@one_hour)
      |> rem(@one_minute)
      |> pad_int()

    "#{h}:#{m}:#{s}"
  end

  def to_hh_mm_ss(seconds) do
    m = div(seconds, @one_minute)

    s =
      seconds
      |> rem(@one_minute)
      |> pad_int()

    "#{m}:#{s}"
  end

  defp pad_int(int, padding \\ 2) do
    int
    |> Integer.to_string()
    |> String.pad_leading(padding, "0")
  end
end
