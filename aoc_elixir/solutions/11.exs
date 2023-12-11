defmodule Day11 do
  def get_input(test \\ false) do
    filename = case test do
      false -> "input/11.txt"
      true -> "test_input/11.txt"
    end
    Input
      # .ints(filename)
      # .line_tokens(filename)
      .lines(filename)
      # .line_of_ints(filename)
      # .ints_in_lines(filename)
  end

  def get_expand_dist({x1, y1}, {x2, y2}, expand_rows, expand_cols) do
    col_padding = Enum.count(expand_cols, fn x -> x > min(x1, x2) and x < max(x1, x2) end)
    row_padding = Enum.count(expand_rows, fn y -> y > min(y1, y2) and y < max(y1, y2) end)
    col_padding + row_padding
  end

  def run(grid, pt2_expand \\ 1000000) do
    max_x = Enum.map(grid, fn {{x, _y}, _val} -> x end) |> Enum.max()
    max_y = Enum.map(grid, fn {{_x, y}, _val} -> y end) |> Enum.max()

    expand_rows = Enum.reduce(0..max_y, [], fn y, acc ->
      filtered_vals = Enum.filter(grid, fn {{_x, y2}, _val} -> y2 == y end)
        |> Enum.map(fn {{_x, _y}, val} -> val end)
      cond do
        Enum.all?(filtered_vals, fn val -> val == "." end) -> [y | acc]
        true -> acc
      end
    end)
    expand_cols = Enum.reduce(0..max_x, [], fn x, acc ->
      filtered_vals = Enum.filter(grid, fn {{x2, _y}, _val} -> x2 == x end)
        |> Enum.map(fn {{_x, _y}, val} -> val end)
      cond do
        Enum.all?(filtered_vals, fn val -> val == "." end) -> [x | acc]
        true -> acc
      end
    end)

    galaxies = Enum.filter(grid, fn {_p, val} -> val == "#" end)
      |> Enum.map(fn {p, _val} -> p end)
    {base, expand} = Enum.reduce(Comb.combinations(galaxies, 2), {0, 0}, fn [g1, g2], {base, expand} ->
      {x1, y1} = g1
      {x2, y2} = g2
      base_dist = abs(x1 - x2) + abs(y1 - y2)
      expand_dist = get_expand_dist(g1, g2, expand_rows, expand_cols)
      {base + base_dist, expand + expand_dist}
    end)
    {base + expand, base + (pt2_expand - 1) * expand}
  end

  def solve(test \\ false) do
    input = get_input(test)
      |> Enum.map(&String.graphemes/1)
      |> Grid.make_grid(true)
    {part1, part2} = run(input)
    IO.puts("Part 1: #{part1}")
    IO.puts("Part 2: #{part2}")
  end
end

Day11.solve()
