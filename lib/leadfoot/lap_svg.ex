defmodule Leadfoot.LapSvg do
  @moduledoc false

  def get_lap(events, lap \\ 0) do
    events
    |> Enum.drop_while(fn x -> x.current_lap_time == 0.0 end)
    |> Enum.filter(fn x -> x.racing == 1 end)
    |> Enum.drop_while(fn x -> x.lap < lap end)
    |> Enum.take_while(fn x -> x.lap == lap end)
  end

  def get_svg_path_from_events(events, x \\ 0, y \\ 2) do
    points = for e <- events, do: "#{-elem(e.position, x)} #{elem(e.position, y)}"
    "M #{Enum.join(points, " \nL ")}"
  end

  def get_svg(events) do
    padding = 20
    x = 0
    y = 2
    xs = Enum.map(events, fn e -> -elem(e.position, x) end)
    ys = Enum.map(events, fn e -> elem(e.position, y) end)
    min_x = xs |> Enum.min()
    min_y = ys |> Enum.min()
    max_x = Enum.max(xs)
    max_y = Enum.max(ys)
    # todo set width and height to maintain aspect ratio
    """
    <?xml version="1.0" standalone="no"?>
    <svg width="10cm" height="10cm" viewBox="
    #{min_x - padding} #{min_y - padding} #{padding + max_x - min_x} #{padding + max_y - min_y}"
             xmlns="http://www.w3.org/2000/svg" version="1.1">
          <path d="#{get_svg_path_from_events(events)}"
        fill="none" stroke="red" stroke-width="3" />
    </svg>
    """
  end
end
