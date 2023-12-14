defmodule Day13 do
  def get_input(test \\ false) do
    filename = case test do
      false -> "input/13.txt"
      true -> "test_input/13.1.txt"
    end
    Input
      # .ints(filename)
      .line_tokens(filename, "\n", "\n\n")
      # .lines(filename, "\n\n\n")
      # .line_of_ints(filename)
      # .ints_in_lines(filename)
  end

  def off_by_one(lstr, rstr) do
    zipped = Enum.zip(String.graphemes(lstr), String.graphemes(rstr))
    Enum.reduce(zipped, 0, fn {l, r}, acc ->
      acc + (if l == r, do: 0, else: 1)
    end) == 1
  end

  def get_mirror({grid, {num_rows, num_cols}}, part2 \\ false) do
    row_res = Enum.reduce_while(1..num_rows-1, nil, fn ridx, _acc ->
      num_check = min(ridx, num_rows-ridx)
      {uimg, dimg} = Enum.reduce(0..num_cols-1, {"", ""}, fn c, {uacc, dacc} ->
        {up, down} = Enum.reduce(1..num_check, {"", ""}, fn r_offset, {up_acc, down_acc} ->
          {up_acc <> Map.get(grid, {ridx - r_offset, c}), down_acc <> Map.get(grid, {ridx + r_offset - 1, c})}
        end)
        {uacc <> up, dacc <> down}
      end)
      cond do
        !part2 and uimg == dimg -> {:halt, ridx}
        part2 and off_by_one(uimg, dimg) -> {:halt, ridx}
        true -> {:cont, nil}
      end
    end)

    case row_res do
      nil ->
        col_res = Enum.reduce_while(1..num_cols-1, nil, fn cidx, _acc ->
          num_check = min(cidx, num_cols-cidx)
          {limg, rimg} = Enum.reduce(0..num_rows-1, {"", ""}, fn r, {lacc, racc} ->
            {left, right} = Enum.reduce(1..num_check, {"", ""}, fn c_offset, {l_acc, r_acc} ->
              {l_acc <> Map.get(grid, {r, cidx - c_offset}), r_acc <> Map.get(grid, {r, cidx + c_offset - 1})}
            end)

            {lacc <> left, racc <> right}
          end)
          cond do
            !part2 and limg == rimg -> {:halt, cidx}
            part2 and off_by_one(limg, rimg) -> {:halt, cidx}
            true -> {:cont, nil}
          end
        end)
        case col_res do
          nil -> raise "No mirror found"
          n -> {:col, n}
        end
      n -> {:row, n}
    end
  end

  def solve(test \\ false) do
    input = get_input(test)
      |> Enum.chunk_every(2)
    grids = input
      |> Enum.map(fn [g1, g2] ->
        l1 = Enum.map(g1, fn l -> String.graphemes(l) end)
        l2 = Enum.map(g2, fn l -> String.graphemes(l) end)
        {Grid.make_grid_with_size(l1), Grid.make_grid_with_size(l2)}
      end)

    part1 = grids
      |> Enum.flat_map(fn {g1, g2} ->
        g1_res = get_mirror(g1)
        g2_res = get_mirror(g2)
        [g1_res, g2_res]
      end)
      |> Enum.reduce(0, fn r, acc ->
        case r do
          {:row, n} -> acc + 100 * n
          {:col, n} -> acc + n
        end
      end)

    part2 = grids
      |> Enum.flat_map(fn {g1, g2} ->
        g1_res = get_mirror(g1, true)
        g2_res = get_mirror(g2, true)
        [g1_res, g2_res]
      end)
      |> Enum.reduce(0, fn r, acc ->
        case r do
          {:row, n} -> acc + 100 * n
          {:col, n} -> acc + n
        end
      end)
    IO.puts("Part 1: #{part1}")
    IO.puts("Part 2: #{part2}")
  end
end

Day13.solve()
