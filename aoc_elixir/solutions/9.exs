defmodule Day9 do
  def get_input(test \\ false) do
    filename = case test do
      false -> "input/9.txt"
      true -> "test_input/9.txt"
    end
    Input
      # .ints(filename)
      # .line_tokens(filename)
      # .lines(filename)
      # .line_of_ints(filename)
      .ints_in_lines(filename)
  end

  def run_history(nums, part2 \\ false) do
    initial = cond do
      part2 -> nums
      true -> Enum.reverse(nums)
    end
    seqs = Enum.reduce_while(1..10000, [initial], fn _i, acc ->
      diffs = Enum.zip(hd(acc), tl(hd(acc)))
        |> Enum.map(fn {a, b} -> a - b end)
      cond do
        Enum.all?(diffs, &(&1 == 0)) -> {:halt, acc}
        true -> {:cont, [diffs | acc]}
      end
    end)
    Enum.reduce(1..Enum.count(seqs)-1, seqs, fn _i, acc ->
      [lower_seq | [next_seq | rem_seqs]] = acc
      diff = hd(lower_seq)
      prior = hd(next_seq)
      [[prior + diff | next_seq] | rem_seqs]
    end)
      |> hd
      |> hd

  end

  def solve(test \\ false) do
    input = get_input(test)
    part1 = Enum.map(input, fn nums -> run_history(nums, false) end)
      |> Enum.sum
    part2 = Enum.map(input, fn nums -> run_history(nums, true) end)
      |> Enum.sum
    IO.puts("Part 1: #{part1}")
    IO.puts("Part 2: #{part2}")
  end
end

Day9.solve()
