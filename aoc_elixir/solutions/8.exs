defmodule Day8 do
  def get_input(test \\ false) do
    filename = case test do
      false -> "input/8.txt"
      true -> "test_input/8.3.txt"
    end
    Input
      # .ints(filename)
      # .line_tokens(filename)
      .lines(filename)
      # .line_of_ints(filename)
  end

  def parse_code(code) do
    [init, left, right] = Utils.get_alpha_num(code)
    {init, {left, right}}
  end

  def run_for_code(instr, start, codes, part2 \\ false) do
    Enum.reduce_while(0..1000000000000, start, fn i, acc ->
      idx = rem(i, String.length(instr))
      op = instr |> String.at(idx)
      next = case op do
        "R" -> Map.get(codes, acc) |> elem(1)
        "L" -> Map.get(codes, acc) |> elem(0)
        _ -> raise "Invalid op: " <> op
      end
      cond do
        !part2 and next == "ZZZ" -> {:halt, i + 1}
        part2 and String.at(next, 2) == "Z" -> {:halt, i + 1}
        true -> {:cont, next}
      end
    end)
  end

  def part2(instr, codes) do
    a_start = Enum.filter(codes, fn{a, {_, _}} -> String.at(a, 2) == "A" end)
      |> Enum.map(fn {a, {_, _}} -> a end)

    results = Enum.map(a_start, fn a -> run_for_code(instr, a, codes, true) end)
    Utils.lcm(results)
  end

  def solve(test \\ false) do
    input = get_input(test)
    [instr | [_blank | raw_codes]] = input
    codes = raw_codes |> Enum.map(fn c -> parse_code(c) end)
      |> Map.new

    part1 = run_for_code(instr, "AAA", codes)
    part2 = part2(instr, codes)
    IO.puts("Part 1: #{part1}")
    IO.puts("Part 2: #{part2}")
  end
end

Day8.solve()
