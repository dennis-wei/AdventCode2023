defmodule Day12 do
  def get_input(test \\ false) do
    filename = case test do
      false -> "input/12.txt"
      true -> "test_input/12.txt"
    end
    Input
      # .ints(filename)
      .line_tokens(filename)
      # .lines(filename)
      # .line_of_ints(filename)
      # .ints_in_lines(filename)
  end

  def q_combos(num_qs) do
    Enum.reduce(1..num_qs, [[]], fn _, acc ->
      Enum.flat_map(acc, fn combo ->
        [combo ++ ["."], combo ++ ["#"]]
      end)
    end)
  end

  def do_replace(line, combo) do
    {replaced, rem_combo} = line
    |> String.graphemes
    |> Enum.reduce({"", combo}, fn c, {str_acc, combo_acc} ->
      cond do
        c == "?" -> {"#{str_acc}#{hd(combo_acc)}", tl(combo_acc)}
        true -> {"#{str_acc}#{c}", combo_acc}
      end
    end)
    cond do
      rem_combo -> replaced
      true -> raise "Combo not used up"
    end

  end

  def pattern_matches(pattern, line) do
    nums = pattern |> Utils.get_all_nums
    split = line |> String.split(".")
      |> Enum.filter(fn s -> s != "" end)
    cond do
      Enum.count(nums) != Enum.count(split) -> false
      true -> Enum.zip(nums, split)
        |> Enum.all?(fn {num, str} ->
          str == String.duplicate("#", num)
        end)
    end
  end

  def get_combos([line, pattern]) do
    num_qs = line
      |> String.graphemes
      |> Enum.filter(fn c -> c == "?" end)
      |> Enum.count
    combos = q_combos(num_qs)
    Enum.reduce(combos, 0, fn combo, acc ->
      replaced = do_replace(line, combo)
      cond do
        pattern_matches(pattern, replaced) -> acc + 1
        true -> acc
      end
    end)
  end

  def unfold([line, pattern]) do
    full_line = cond do
      !part2 -> line
      true -> List.duplicate(line, 5)
        |> Enum.reduce("", fn l, acc -> "#{acc}?#{l}" end)
    end
    full_pattern = cond do
      !part2 -> pattern
      true -> List.duplicate(pattern, 5)
        |> Enum.reduce("", fn p, acc -> "#{acc},#{p}" end)
    end

    [full_line, full_pattern]
  end

  def get_combos_dp([line, pattern]) do
    state = {0, line, pattern}
    # {num_poss, remaining_line, remaining_pattern, combos}
    # On #, append to all remaining combos
    # On ?, add "#" and append "#" to all remaining combos


  end

  def solve(test \\ true) do
    input = get_input(test)
    part1 = input
      |> Enum.map(fn line -> get_combos(line) end)
      |> Enum.sum
    part2 = input
      |> Enum.map(fn line -> unfold(line) end)
      |> Enum.map(fn line -> get_combos_dp(line) end)
      |> Enum.sum
    IO.puts("Part 1: #{part1}")
    IO.puts("Part 2: #{part2}")
  end
end

Day12.solve()
