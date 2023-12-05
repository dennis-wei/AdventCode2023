defmodule Day3 do
  def get_input(test \\ false) do
    filename = case test do
      false -> "input/3.txt"
      true -> "test_input/3.txt"
    end
    Input
      # .ints(filename)
      # .line_tokens(filename)
      .lines(filename)
      # .line_of_ints(filename)
  end

  def neighboring_symbol(grid, x, y) do
    Grid.get_neighbors(grid, {x, y}, true)
      |> Map.values
      |> Enum.any?(fn n -> !String.contains?("1234567890.", n) end)
  end

  def run(grid) do
    max_x = grid
      |> Map.keys
      |> Enum.map(fn {x, _y} -> x end)
      |> Enum.max
    max_y = grid
      |> Map.keys
      |> Enum.map(fn {_x, y} -> y end)
      |> Enum.max

    {num_locs, {_, _}} = Enum.reduce(0..max_x, {[], {[], ""}}, fn x, {ret, {cacc, nacc}} ->
      Enum.reduce(0..max_y, {ret, {cacc, nacc}}, fn y, {ret, {cacc, nacc}} ->
        c = Map.get(grid, {x, y})
        {uret, {ucacc, unacc}} = cond do
          Regex.match?(~r/^\d$/, c) -> {ret, {[{x, y} | cacc], "#{nacc}#{c}"}}
          nacc != "" -> {[{cacc, String.to_integer(nacc)} | ret], {[], ""}}
          true -> {ret, {[], ""}}
        end
        cond do
          y == max_y and unacc != "" -> {[{ucacc, String.to_integer(unacc)} | uret], {[], ""}}
          true -> {uret, {ucacc, unacc}}
        end
      end)
    end)

    symbol_adjacent = Enum.filter(num_locs, fn {coords, _n} ->
      Enum.any?(coords, fn {x, y} -> neighboring_symbol(grid, x, y) end)
    end)

    part1 = Enum.reduce(symbol_adjacent, 0, fn {_coords, n}, acc -> acc + n end)

    gears = Enum.filter(grid, fn {_c, v} -> v == "*" end)
      |> Enum.map(fn {c, _v} -> c end)
    gear_pairs = Enum.reduce(gears, %{}, fn gear_coords, acc ->
      adjacent_nums = Enum.filter(num_locs, fn {coords, _n} ->
        Enum.any?(coords, fn {x, y} -> Grid.get_neighbors(grid, {x, y}, true) |> Map.has_key?(gear_coords) end)
      end)
      cond do
        length(adjacent_nums) == 2 ->
          Map.put(acc, gear_coords, Enum.map(adjacent_nums, fn {_coords, n} -> n end))
        true -> acc
      end
    end)
    part2 = gear_pairs
      |> Map.values
      |> Enum.map(fn [n1, n2] -> n1 * n2 end)
      |> Enum.sum
    {part1, part2}
  end

  def solve(test \\ false) do
    input = get_input(test)
      |> Enum.map(&String.graphemes/1)
      |> Grid.make_grid
    {part1, part2} = run(input)
    IO.puts("Part 1: #{part1}")
    IO.puts("Part 2: #{part2}")
  end
end

Day3.solve()
