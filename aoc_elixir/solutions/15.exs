defmodule Day15 do
  def get_input(test \\ false) do
    filename = case test do
      false -> "input/15.txt"
      true -> "test_input/15.txt"
    end
    Input
      # .ints(filename)
      # .line_tokens(filename)
      .lines(filename)
      # .line_of_ints(filename)
      # .ints_in_lines(filename)
  end

  def hash(s) do
    s |> String.to_charlist
      |> Enum.reduce(0, fn c , acc -> rem((acc + c) * 17, 256) end)
  end

  def pt2(input) do
    start = Enum.reduce(0..255, %{}, fn i, acc -> Map.put(acc, i, []) end)
    res = Enum.reduce(input, start, fn s, acc ->
      cond do
        String.contains?(s, "=") ->
          [code, raw_val] = String.split(s, "=")
          val = String.to_integer(raw_val)
          hash = hash(code)
          existing = Map.get(acc, hash)
          cond do
            existing == nil -> raise "no list present"
            true ->
              updated = case Enum.find_index(existing, fn {k, _v} -> k == code end) do
                nil -> existing ++ [{code, val}]
                n -> List.replace_at(existing, n, {code, val})
              end
              Map.put(acc, hash, updated)
          end
        String.contains?(s, "-") ->
          [code, _] = String.split(s, "-")
          hash = hash(code)
          existing = Map.get(acc, hash)
          cond do
            existing == nil -> raise "no list present"
            true ->
              updated = case Enum.find_index(existing, fn {k, _v} -> k == code end) do
                nil -> existing
                n -> List.delete_at(existing, n)
              end
              Map.put(acc, hash, updated)
          end
        true -> raise "bad input: #{s}"
      end
    end)
    Enum.reduce(res, 0, fn {k, vals}, acc ->
      pts = Enum.map(vals |> Enum.with_index, fn {{_code, val}, i} -> (k + 1) * (i + 1) * val end)
      acc + Enum.sum(pts)
    end)
  end

  def solve(test \\ false) do
    input = get_input(test)
      |> hd
      |> String.split(",")
    part1 = input
      |> Enum.map(fn s -> hash(s) end)
      |> Enum.sum
    part2 = pt2(input)
    IO.puts("Part 1: #{part1}")
    IO.puts("Part 2: #{part2}")
  end
end

Day15.solve()
