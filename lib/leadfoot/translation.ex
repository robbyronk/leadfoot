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

  def to_hh_mm_ss(seconds) do
    time = Time.from_seconds_after_midnight(round(seconds))

    [time.hour, time.minute, time.second]
    |> Enum.drop_while(fn x -> x == 0 end)
    |> Enum.map(&Integer.to_string/1)
    |> Enum.map(&String.pad_leading(&1, 2, "0"))
    |> Enum.join(":")
  end

  def to_mm_ss_ms(seconds) do
    time = Time.add(~T[00:00:00], round(seconds * 1000), :millisecond)

    {ms, _precision} = time.microsecond

    mm_ss =
      [time.hour * 60 + time.minute, time.second]
      |> Enum.drop_while(fn x -> x == 0 end)
      |> Enum.map(&Integer.to_string/1)
      |> Enum.map(&String.pad_leading(&1, 2, "0"))
      |> Enum.join(":")

    "#{mm_ss}.#{div(ms, 1000)}"
  end
end
