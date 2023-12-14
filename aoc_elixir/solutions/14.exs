defmodule Day14 do
  def get_input(test \\ false) do
    filename = case test do
      false -> "input/14.txt"
      true -> "test_input/14.txt"
    end
    Input
      # .ints(filename)
      # .line_tokens(filename)
      .lines(filename)
      # .line_of_ints(filename)
      # .ints_in_lines(filename)
  end

  def swap(s, i1, i2) do
    start = case i1 do
     0 -> ""
      _ -> String.slice(s, 0..i1-1)
    end

    start <> String.at(s, i2) <> String.slice(s, i1+1..i2-1) <> String.at(s, i1) <> String.slice(s, i2+1..-1)
  end

  def tilt(str) do
    Enum.reduce(0..String.length(str)-1, str, fn i, acc ->
      c = String.at(acc, i)
      case c do
        "." ->
          slice = String.slice(acc, i+1..-1)
          {next_round, _} = slice
            |> :binary.match("O")
            |> case do
              :nomatch -> {:nomatch, nil}
              t -> t
            end
          {next_cube, _} = slice
            |> :binary.match("#")
            |> case do
              :nomatch -> {String.length(str), nil}
              n -> n
            end
          cond do
            next_round == :nomatch -> acc
            next_cube < next_round -> acc
            next_round < next_cube -> swap(acc, i, next_round+i+1)
            true -> raise "Invalid stat"
          end
        "O" -> acc
        "#" -> acc
        _ -> raise "Invalid char #{c}"
      end
    end)
  end

  def tilt(grid, {dx, dy}, dir) do
    case dir do
      :north -> Enum.reduce(0..dy-1, %{}, fn y, acc ->
        slice = Enum.reduce(0..dx-1, "", fn x, acc ->
          c = Map.get(grid, {x, y})
          cond do
            c == nil -> raise "Invalid coord #{x}, #{y}"
            true -> acc <> c
          end
        end)
        tilted = tilt(slice)
        Enum.reduce(0..dx-1, acc, fn x, acc ->
          c = String.at(tilted, x)
          Map.put(acc, {x, y}, c)
        end)
      end)
      :south -> Enum.reduce(0..dy-1, %{}, fn y, acc ->
        slice = Enum.reduce(dx-1..0, "", fn x, acc ->
          c = Map.get(grid, {x, y})
          cond do
            c == nil -> raise "Invalid coord #{x}, #{y}"
            true -> acc <> c
          end
        end)
        tilted = tilt(slice)
          |> String.reverse
        Enum.reduce(0..dx-1, acc, fn x, acc ->
          c = String.at(tilted, x)
          Map.put(acc, {x, y}, c)
        end)
      end)
      :west -> Enum.reduce(0..dx-1, %{}, fn x, acc ->
        slice = Enum.reduce(0..dy-1, "", fn y, acc ->
          c = Map.get(grid, {x, y})
          cond do
            c == nil -> raise "Invalid coord #{x}, #{y}"
            true -> acc <> c
          end
        end)
        tilted = tilt(slice)
        Enum.reduce(0..dy-1, acc, fn y, acc ->
          c = String.at(tilted, y)
          Map.put(acc, {x, y}, c)
        end)
      end)
      :east -> Enum.reduce(0..dx-1, %{}, fn x, acc ->
        slice = Enum.reduce(dy-1..0, "", fn y, acc ->
          c = Map.get(grid, {x, y})
          cond do
            c == nil -> raise "Invalid coord #{x}, #{y}"
            true -> acc <> c
          end
        end)
        tilted = tilt(slice)
          |> String.reverse
        Enum.reduce(0..dy-1, acc, fn y, acc ->
          c = String.at(tilted, y)
          Map.put(acc, {x, y}, c)
        end)
      end)
    end
  end

  def calc_load(grid, {dx, _dy}) do
    Enum.reduce(grid, 0, fn {{x, _y}, v}, acc ->
      case v do
        "O" -> acc + (dx - x)
        _ -> acc
      end
    end)
  end

  def cycle(grid, size) do
    grid
      |> tilt(size, :north)
      |> tilt(size, :west)
      |> tilt(size, :south)
      |> tilt(size, :east)
  end

  def solve(test \\ false) do
    {grid, size} = get_input(test)
      |> Enum.map(fn l -> String.graphemes(l) end)
      |> Grid.make_grid_with_size
    p1_tilted = grid
      |> tilt(size, :north)
    part1 = p1_tilted
      |> calc_load(size)

    {cycle_start, cycle_length, map} = Enum.reduce_while(1..10000, {grid, %{grid => 0}}, fn i, {grid_acc, seen} ->
      cycled = cycle(grid_acc, size)
      useen = Map.put(seen, cycled, i)
      cond do
        Map.has_key?(seen, cycled) ->
          start = Map.get(seen, cycled)
          {:halt, {start, i - start, seen}}
        true -> {:cont, {cycled, useen}}
      end
    end)
    offset = rem(1000000000 - cycle_start, cycle_length)
    part2 = Enum.filter(map, fn {_k, v} -> v == cycle_start + offset end)
      |> Enum.map(fn {k, _v} -> calc_load(k, size) end)
      |> hd()

    IO.puts("Part 1: #{part1}")
    IO.puts("Part 2: #{part2}")
  end
end

Day14.solve()
